# RailRoad - RoR diagrams generator
# http://railroad.rubyforge.org
#
# Copyright 2007-2008 - Javier Smaldone (http://www.smaldone.com.ar)
# See COPYING for more details

require 'railroad/app_diagram'
require 'railroad/model_factory'

# RailRoad models diagram
class ModelsDiagram < AppDiagram

  def initialize(options)
    #options.exclude.map! {|e| "app/models/" + e}
    super options 
    @graph.diagram_type = 'Models'
  end

  # Process model files
  def generate
    STDERR.print "Generating models diagram\n" if @options.verbose
    files = Dir.glob("app/models/**/*.rb")
    files += Dir.glob("vendor/plugins/**/app/models/*.rb") if @options.plugins_models    
    files -= @options.exclude
    files.each do |f| 
      process_class constantize(extract_class_name(f))
    end
  end 

  private

  # Load model classes
  def load_classes
    begin
      disable_stdout
      files = Dir.glob("app/models/**/*.rb")
      files += Dir.glob("vendor/plugins/**/app/models/*.rb") if @options.plugins_models
      files -= @options.exclude
      files.each {|m| require m }
      enable_stdout
    rescue LoadError
      enable_stdout
      print_error "model classes"
      raise
    end
  end  # load_classes
    
  # Process a model class
  def process_class(current_class)

    STDERR.print "\tProcessing #{current_class}\n" if @options.verbose

    model = ModelFactory.getModel(current_class, @options)
    node_attribs = []
    edges = []
    nodes = []
    if @options.brief || model.abstract?
      node_type = 'model-brief'
    else 
      node_type = 'model'
      node_attribs += model.attributes unless model.nil?
    end
    nodes << [node_type, current_class.name, node_attribs]
    
    if !model.nil?
      edges += model.edges
      # Only consider meaningful inheritance relations classes
      if @options.inheritance && model.meaningful?
        edges << ['is-a', current_class.superclass.name, current_class.name]
      end
    elsif @options.all && (current_class.is_a? Class)
      # Not database model
      node_type = @options.brief ? 'class-brief' : 'class'
      nodes << [node_type, current_class.name]
      edges << ['is-a', current_class.superclass.name, current_class.name]
    elsif @options.modules && (current_class.is_a? Module)
      nodes << ['module', current_class.name]
    end
    nodes.compact.each {|node| @graph.add_node node}
    edges.compact.each {|edge| @graph.add_edge edge}
  end # process_class
  
end # class ModelsDiagram
