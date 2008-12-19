require 'railroad/ar_model'
require 'railroad/dm_model'

# A factory for discovering the ORM being used that will then return the
# corresponding "model" that will be used to interact with the ORM.  Will
# return nil if unable to discover a supported ORM.
#
# Dec 2008 - Roy Wright
# created to support multiple ORMs
#
class ModelFactory
  def self.getModel(klass, options)
    model = nil
    model = AR_Model.new(klass, options) if klass.respond_to?'reflect_on_all_associations'
    model = DM_Model.new(klass, options) if klass.respond_to?'relationships'
    model
  end
  
  private
  
  # prevent instantiation
  def initialize
  end
end

