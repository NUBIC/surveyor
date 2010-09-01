class ValidationCondition < ActiveRecord::Base
  unloadable
  include Surveyor::Models::ValidationConditionMethods
end
