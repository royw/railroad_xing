# A class that encapsulates the interaction with the Merb framework.
#
# Note, will use the 'test' envirnoment and database.
#
# Warning, will automigrate the 'test' database
#
# Dec 2008 - Roy Wright
# created to support the Merb application framework
#
class MerbFramework
  attr_reader :name, :migration_version
  
  # enter the merb 'test' environment
  def initialize
    require 'merb-core'
    Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')
    DataMapper.auto_migrate!
    @name = 'Merb'
    @migration_version = nil
  end
  
  # is the given class a subclass of the application controller?
  def is_application_subclass?(klass)
    (Application.subclasses_list.include? klass.name)
  end
  
  # get the controller's files returning the application controller first in returned array
  def get_controller_files(options)
    files = []
    files << 'app/controllers/application.rb'
    files += Dir.glob("app/controllers/**/*.rb") - options.exclude
    files.uniq
  end
  
  # Extract class name from filename
  def extract_class_name(filename)
    File.basename(filename).chomp(".rb").camel_case
  end

  # convert the give string to a constant
  def constantize(str)
    Object.full_const_get(str)
  end

end
