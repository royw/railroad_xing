# The "model" used to interact with DataMapper models.
#
# Dec 2008 - Roy Wright
# created based on code from models_diagram adapted for DataMapper models.
#
class DM_Model
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
      magic_fields = [
      "created_at", "created_on", "updated_at", "updated_on",
      "lock_version", "type", "id", "position", "parent_id", "lft", 
      "rgt", "quote", "template", "count"
      ]
      content_columns = @klass.properties.select {|c| ! magic_fields.include? c.field}
    else
      content_columns = @klass.properties
    end
    
    content_columns.each do |a|
      content_column = a.field
      content_column += ' :' + a.type.to_s unless @options.hide_types
      attribs << content_column
    end
    attribs
  end
  
  # is the model abstract?
  def abstract?
    # TODO: does datamapper support the abstract concept?
    false
  end
  
  # return the model edges (relationships)
  def edges
    found_edges = []
    # Process class relationships
    relationships = @klass.relationships

    if @options.inheritance && ! @options.transitive
      if @klass.superclass.respond_to?'relationships'
        superclass_relationships = @klass.superclass.relationships
        relationships = relationships.select{|k,a| superclass_relationships[k].nil?} 
      end
    end
    remove_joins(relationships).each do |k, a|
      found_edges << process_relationship(@klass.name, a)
    end
    found_edges.compact
  end
  
  # is the model meaningful?
  def meaningful?
    (@klass.superclass != Object)
  end
  
  protected

  # datamapper's relationships for HABTM fully map the relationship
  # from each end.  We do not want to duplicate relationship arrows
  # on the graph, so remove the duplicates here.
  def remove_joins(relationships)
    new_relationships = {}
    join_names = []
    relationships.each do |k,v|
      if v.kind_of? DataMapper::Associations::RelationshipChain
        join_names << v.name
      end
    end
    relationships.each do |k,v|
      unless join_names.include? k
        new_relationships[k] = v
      end
    end
    new_relationships
  end

  # Process a model association
  def process_relationship(class_name, relationship)
    STDERR.print "\t\tProcessing model relationship #{relationship.name.to_s}\n" if @options.verbose

    assoc_type = nil
    # Skip "belongs_to" relationships
    unless relationship.options.empty?
      # Only non standard association names needs a label
      assoc_class_name = (relationship.child_model.respond_to? 'underscore') ? 
                            relationship.child_model.underscore.singularize.camelize : 
                            relationship.child_model
      if assoc_class_name == relationship.name.to_s.singularize.camel_case
        assoc_name = ''
      else
        assoc_name = relationship.name.to_s
      end 

      assoc_type = nil
      if has_one_relationship?(relationship)
        assoc_type = 'one-one'
      elsif has_many_relationship?(relationship) && !has_through_relationship?(relationship)
        assoc_type = 'one-many'
      elsif has_many_relationship?(relationship) && has_through_relationship?(relationship)
        if relationship.kind_of? DataMapper::Associations::RelationshipChain
          assoc_name = relationship.options[:remote_relationship_name]
        end
        return if @habtm.include? [relationship.child_model, class_name, assoc_name]
        assoc_type = 'many-many'
        @habtm << [class_name, relationship.child_model, assoc_name]
      end  
    end
    assoc_type.nil? ? nil : [assoc_type, class_name, assoc_class_name, assoc_name]    
  end # process_association

  # is this relationship a has n, through?
  def has_through_relationship?(relationship)
    result = false
    # names are symbols
    near_name = relationship.options[:near_relationship_name]
    remote_name = relationship.options[:remote_relationship_name]
    unless near_name.nil? || remote_name.nil?
      # ok, both near and remote have names
      result = (near_name != remote_name)
    end
    result
  end

  # is this relationship a has 1?
  def has_one_relationship?(relationship)
    (relationship.options[:min] == 1) && (relationship.options[:max] == 1)
  end

  # is this relationship a has n?
  def has_many_relationship?(relationship)
    !relationship.options[:max].nil? && (relationship.options[:max] != 0) && (relationship.options[:max] != 1)
  end

end
