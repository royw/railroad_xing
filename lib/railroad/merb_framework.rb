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
    case Merb::Config[:merb_orm]
      when :datamapper: DataMapper.auto_migrate!
      when :activerecord: ActiveRecord::Migrator.migrate(File.expand_path(File.dirname(__FILE__) + "/schema/migrations"))
    end
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
    # handle subdirectories as modules
    # i.e., app/controllers/foo/bar.rb => Foo::Bar
    if filename =~ /^app\/controllers\/(.*)\.rb$/
      class_name = $1.split('/').collect {|part| part.camel_case}.join('::')
    else
      class_name = File.basename(filename).chomp(".rb").camel_case
    end
    class_name
  end

  # convert the give string to a constant
  def constantize(str)
    Object.full_const_get(str)
  end

end
