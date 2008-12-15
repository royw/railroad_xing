# A class that encapsulates the interaction with the Rails framework.
#
class RailsFramework
  attr_reader :name, :migration_version
  
  def initialize
    require "config/environment"
    @name = 'Rails'
    @migration_version = ActiveRecord::Migrator.current_version
  end
  
  # is the given class a subclass of the application controller?
  def is_application_subclass?(klass)
    (ApplicationController.subclasses.include? klass.name)
  end
  
  # get the controller's files returning the application controller first in returned array
  def get_controller_files(options)
    files = []
    files << 'app/controllers/application.rb'
    files += Dir.glob("app/controllers/**/*_controller.rb") - options.exclude
    files.uniq
  end
  
  # Extract class name from filename
  def extract_class_name(filename)
    class_name = File.basename(filename).chomp(".rb").camelize

    if filename == 'app/controllers/application.rb'
      # ApplicationController's file is 'application.rb'
      class_name += 'Controller' if class_name == 'Application'
    end
    class_name
  end
  
  # convert the give string to a constant
  def constantize(str)
    str.constantize
  end
  
end

