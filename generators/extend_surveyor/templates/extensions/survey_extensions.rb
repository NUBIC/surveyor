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
    # def title
    #   foo
    # end
    # def foo
    #   "bar"
    # end
  end
end

# Add "survey" to config['extend'] array in config/initializers/surveyor.rb to activate these extensions
