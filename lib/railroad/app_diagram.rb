# RailRoad - RoR diagrams generator
# http://railroad.rubyforge.org
#
# Copyright 2007-2008 - Javier Smaldone (http://www.smaldone.com.ar)
# See COPYING for more details
#
# Dec 2008 - Roy Wright
# added FrameworkFactory to support multiple application frameworks

require 'railroad/diagram_graph'
require 'railroad/framework_factory'

# Root class for RailRoad diagrams
class AppDiagram

  def initialize(options)
    @options = options
    @graph = DiagramGraph.new
    @graph.show_label = @options.label

    STDERR.print "Loading application environment\n" if @options.verbose
    load_environment

    STDERR.print "Loading application classes\n" if @options.verbose
    load_classes
  end

  # Print diagram
  def print
    if @options.output
      old_stdout = STDOUT.dup
      begin
        STDOUT.reopen(@options.output)
      rescue
        STDERR.print "Error: Cannot write diagram to #{@options.output}\n\n"
        exit 2
      end
    end
    
    if @options.xmi 
      STDERR.print "Generating XMI diagram\n" if @options.verbose
    	STDOUT.print @graph.to_xmi
    else
      STDERR.print "Generating DOT graph\n" if @options.verbose
      STDOUT.print @graph.to_dot 
    end

    if @options.output
      STDOUT.reopen(old_stdout)
    end
  end # print

  private 

  # Prevents Rails application from writing to STDOUT
  def disable_stdout
    @old_stdout = STDOUT.dup
    STDOUT.reopen(PLATFORM =~ /mswin/ ? "NUL" : "/dev/null")
  end

  # Restore STDOUT  
  def enable_stdout
    STDOUT.reopen(@old_stdout)
  end


  # Print error when loading Rails application
  def print_error(type)
    STDERR.print "Error loading #{type}.\n  (Are you running " +
                 "#{APP_NAME} on the application's root directory?)\n\n"
  end

  # Load Rails application's environment
  def load_environment
    begin
      disable_stdout
      @framework = FrameworkFactory.getFramework
      raise LoadError.new if @framework.nil?
      @graph.migration_version = @framework.migration_version
      enable_stdout
    rescue LoadError
      enable_stdout
      print_error "application environment"
      raise
    end
  end
  
  # is the given class a subclass of the application controller?
  def is_application_subclass?(klass)
    @framework.is_application_subclass?(klass)
  end
  
  # get the controller's files returning the application controller first in returned array
  def get_controller_files(options)
    @framework.get_controller_files(options)
  end

  # Extract class name from filename
  def extract_class_name(filename)
    @framework.extract_class_name(filename)
  end

  # convert the give string to a constant
  def constantize(str)
    @framework.constantize(str)
  end
  
end # class AppDiagram

