# A factory that determines if railroad is running in an application
# framework and if so, returns a "framework" object that handles interacting
# with the framework.  If the factory can not determine find a framework,
# then the factory will return nil.
#
# === Usage
# 
# framework = FrameworkFactory.getFramework
#
# Dec 2008 - Roy Wright
# created to support multiple frameworks
#
class FrameworkFactory
  
  # the factory the returns a "framework" object or nil
  def self.getFramework
    framework = nil
    if File.exist? 'merb'
      require 'railroad/merb_framework'
      framework = MerbFramework.new 
    end
    if File.exist? 'script/server'
      require 'railroad/rails_framework'
      framework = RailsFramework.new 
    end
    framework
  end
  
  private
  
  # prevent instantiation
  def initialize
  end
end

