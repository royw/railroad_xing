# The "model" used to interact with ActiveRecord models.
# 
# Dec 2008 - Roy Wright
# created class an refactored logic from models_diagram.rb
#
class AR_Model
  def initialize(klass, options)
    @klass = klass
    @options = options
    # Processed habtm associations
    @habtm = []
  end
  
  # return an Array of attribute (column) "name:type" strings for the 
  # model.
  # if @options.hide_magic is asserted, then remove some standard
  # attribute names from the array.
  # if @options.hide_types is asserted, then the returned strings are
  # just the names "name".
  def attributes
    attribs = []

    if @options.hide_magic 
      # From patch #13351
      # http://wiki.rubyonrails.org/rails/pages/MagicFieldNames
      magic_fields = [
      "created_at", "created_on", "updated_at", "updated_on",
      "lock_version", "type", "id", "position", "parent_id", "lft", 
      "rgt", "quote", "template"
      ]
      magic_fields << @klass.table_name + "_count" if @klass.respond_to? 'table_name' 
      content_columns = @klass.content_columns.select {|c| ! magic_fields.include? c.name}
    else
      content_columns = @klass.content_columns
    end
    
    content_columns.each do |a|
      content_column = a.name
      content_column += ' :' + a.type.to_s unless @options.hide_types
      attribs << content_column
    end
    attribs
  end
  
  # is the model abstract?
  def abstract?
    @klass.abstract_class?
  end
  
  # return the model edges (relationships)
  def edges
    found_edges = []
    # Process class associations
    associations = @klass.reflect_on_all_associations
    if @options.inheritance && ! @options.transitive
      superclass_associations = @klass.superclass.reflect_on_all_associations
      
      associations = associations.select{|a| ! superclass_associations.include? a} 
      # This doesn't works!
      # associations -= current_class.superclass.reflect_on_all_associations
    end
    associations.each do |a|
      found_edges << process_association(@klass.name, a)
    end
    found_edges.compact
  end
  
  # is the model meaningful?
  def meaningful?
    (@klass.superclass != ActiveRecord::Base) && (@klass.superclass != Object)
  end
  
  protected
  
  # Process a model association
  def process_association(class_name, assoc)
    STDERR.print "\t\tProcessing model association #{assoc.name.to_s}\n" if @options.verbose

    assoc_type = nil
    # Skip "belongs_to" associations
    unless assoc.macro.to_s == 'belongs_to'
      # Only non standard association names needs a label
      assoc_class_name = (assoc.class_name.respond_to? 'underscore') ? assoc.class_name.underscore.singularize.camelize : assoc.class_name 
      if assoc_class_name == assoc.name.to_s.singularize.camelize
        assoc_name = ''
      else
        assoc_name = assoc.name.to_s
      end 

      if assoc.macro.to_s == 'has_one' 
        assoc_type = 'one-one'
      elsif assoc.macro.to_s == 'has_many' && (! assoc.options[:through])
        assoc_type = 'one-many'
      else # habtm or has_many, :through
        return if @habtm.include? [assoc.class_name, class_name, assoc_name]
        assoc_type = 'many-many'
        @habtm << [class_name, assoc.class_name, assoc_name]
      end  
    end
    assoc_type.nil? ? nil : [assoc_type, class_name, assoc_class_name, assoc_name]    
  end # process_association

end
