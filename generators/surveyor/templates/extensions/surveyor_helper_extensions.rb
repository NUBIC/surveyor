module SurveyorHelperExtensions
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
    base.class_eval do
      # Same as typing in the module
      # alias_method_chain :question_number_helper, :sauce
    end
  end
  
  module InstanceMethods
    # def question_number_helper_with_sauce(number)
    #   question_number_helper_without_sauce(number) + "Extra sauce"
    # end
  end
end

# Add module to SurveyorHelper
SurveyorHelper.send(:include, SurveyorHelperExtensions)