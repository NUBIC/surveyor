module SurveyExtensions
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      # Same as typing in the class
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
end

# Add module to Survey
Survey.send(:include, SurveyExtensions)