# RailRoad - RoR diagrams generator
# http://railroad.rubyforge.org
#
# Copyright 2007-2008 - Javier Smaldone (http://www.smaldone.com.ar)
# See COPYING for more details

# AASM code provided by Ana Nelson (http://ananelson.com/)

# Dec 2008 - Roy Wright
# enable only for Rails as AASM is a Rails plugin

require 'railroad/app_diagram'

# Diagram for Acts As State Machine
class AasmDiagram < AppDiagram

  def initialize(options)
    #options.exclude.map! {|e| e = "app/models/" + e}
    super options 
    @graph.diagram_type = 'Models'
    # Processed habtm associations
    @habtm = []
  end

  # Process model files
  def generate
    STDERR.print "Generating AASM diagram\n" if @options.verbose
    
    generate_new_aasm
        
    files = Dir.glob("app/models/**/*.rb") 
    files += Dir.glob("vendor/plugins/**/app/models/*.rb") if @options.plugins_models
    files -= @options.exclude
    files.each do |f| 
      process_class extract_class_name(f).constantize
    end
  end
  
  private
  
  # Load model classes
  def load_classes
    unless @framework.name == 'Rails'
      print_error 'AASM diagrams only supported for Rails'
      raise LoadError.new
    end
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
    
    # Only interested in acts_as_state_machine models.
    return unless current_class.respond_to?'states'
    
    node_attribs = []
    node_type = 'aasm'
    
    current_class.states.each do |state_name|
      state = current_class.read_inheritable_attribute(:states)[state_name]
      node_shape = (current_class.initial_state === state_name) ? ", peripheries = 2" : ""
      node_attribs << "#{current_class.name.downcase}_#{state_name} [label=#{state_name} #{node_shape}];"
    end
    @graph.add_node [node_type, current_class.name, node_attribs]
    
    current_class.read_inheritable_attribute(:transition_table).each do |event_name, event|
      event.each do |transition|
        @graph.add_edge [
          'event', 
          current_class.name.downcase + "_" + transition.from.to_s, 
          current_class.name.downcase + "_" + transition.to.to_s, 
          event_name.to_s
        ]
      end
    end
  end # process_class
  
  def generate_new_aasm
    if defined?(AASM) && defined?(AASM::StateMachine) && (machines =   AASM::StateMachine.instance_variable_get(:'@machines'))
        machines.map {|k, v| [k.first.name, v.states, v.events, v.initial_state]}.each do |name, states, events, initial_state|
          states.each do |state|
            node_shape = (initial_state == state.name) ? ", peripheries = 2" : ""
            node_attribs = ["#{name.underscore}_#{state.name} [label=#{state.name} #{node_shape}];"]
            @graph.add_node ['aasm', name, node_attribs]
          end

          events.each do |event_name, event|
            event.instance_variable_get(:'@transitions').each do |transition|              
              [*transition.from].each do |from|
                @graph.add_edge [
                  'event', 
                  name.underscore + "_" + transition.from.to_s, 
                  name.underscore + "_" + transition.to.to_s, 
                  event.name.to_s
                ]
              end
            end
          end
      end
    end
  end

end # class AasmDiagram
