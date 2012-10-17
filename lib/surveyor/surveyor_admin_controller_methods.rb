module Surveyor
  module SurveyorAdminControllerMethods
    def self.included(base)
      # base.send :before_filter, :get_current_user, :only => [:new, :create]
      # base.send :layout, 'surveyor_default'
    end

    # Actions
    def new

    end

    def create
    end


    def show
    end

    def edit
    end

    def update
    end

    private

    # This is a hoock method for surveyor-using applications to override and provide the context object
    def render_context
      nil
    end

    # Filters
    def get_current_user
      @current_user = self.respond_to?(:current_user) ? self.current_user : nil
    end

    def set_render_context
      @render_context = render_context
    end

    def redirect_with_message(path, message_type, message)
      respond_to do |format|
        format.html do
          flash[message_type] = message if !message.blank? and !message_type.blank?
          redirect_to path
        end
        format.js do
          render :text => message, :status => 403
        end
      end
    end
    
  end
end