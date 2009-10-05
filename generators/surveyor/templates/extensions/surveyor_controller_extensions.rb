module SurveyorControllerExtensions
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      # Same as typing in the class
      # before_filter :pimp_my_ride
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    # def pimp_my_ride
    #   flash[:notice] = "pimped!"
    # end
  end
  
  module Actions
    # Redefine the controller actions [index, new, create, show, update] here
    # def new
    #   render :text =>"surveys are down"
    # end
  end
end

# Set config['extend_controller'] = true in config/initializers/surveyor.rb to activate these extensions
