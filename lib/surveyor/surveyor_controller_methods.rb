module Surveyor
  module SurveyorControllerMethods
    def self.included(base)
      base.send :before_filter, :get_current_user, :only => [:new, :create]
      base.send :layout, 'surveyor_default'
    end

    # Actions
    def new
      @surveys = Survey.find(:all)
      @title = "You can take these surveys"
      redirect_to surveyor_index unless surveyor_index == available_surveys_path
    end

    def create
      @survey = Survey.find_by_access_code(params[:survey_code])
      @response_set = ResponseSet.create(:survey => @survey, :user_id => (@current_user.nil? ? @current_user : @current_user.id))
      if (@survey && @response_set)
        flash[:notice] = t('surveyor.survey_started_success')
        redirect_to(edit_my_survey_path(:survey_code => @survey.access_code, :response_set_code  => @response_set.access_code))
      else
        flash[:notice] = t('surveyor.Unable_to_find_that_survey')
        redirect_to surveyor_index
      end
    end

    def show
      @response_set = ResponseSet.find_by_access_code(params[:response_set_code], :include => {:responses => [:question, :answer]})
      if @response_set
        @survey = @response_set.survey
        respond_to do |format|
          format.html #{render :action => :show}
          format.csv {
            send_data(@response_set.to_csv, :type => 'text/csv; charset=utf-8; header=present',:filename => "#{@response_set.updated_at.strftime('%Y-%m-%d')}_#{@response_set.access_code}.csv")
          }
        end
      else
        flash[:notice] = t('surveyor.unable_to_find_your_responses')
        redirect_to surveyor_index
      end
    end

    def edit
      @response_set = ResponseSet.find_by_access_code(params[:response_set_code], :include => {:responses => [:question, :answer]})
      if @response_set
        @survey = Survey.with_sections.find_by_id(@response_set.survey_id)
        @sections = @survey.sections
        if params[:section]  
          @section = @sections.with_includes.find(section_id_from(params[:section])) || @sections.with_includes.first 
        else
          @section = @sections.with_includes.first
        end
        @questions = @section.questions
        @dependents = (@response_set.unanswered_dependencies - @section.questions) || []
      else
        flash[:notice] = t('surveyor.unable_to_find_your_responses')
        redirect_to surveyor_index
      end
    end

    def update
      saved = nil
      ActiveRecord::Base.transaction do 
        if @response_set = ResponseSet.find_by_access_code(params[:response_set_code], :include => {:responses => :answer},:lock => true)
          @response_set.current_section_id = params[:current_section_id]
        else
          flash[:notice] = t('surveyor.unable_to_find_your_responses')
          redirect_to(available_surveys_path) and return
        end

        if params[:responses] or params[:response_groups]
          @response_set.clear_responses
          saved = @response_set.update_attributes(:response_attributes => (params[:responses] || {}).dup ,
                                                  :response_group_attributes => (params[:response_groups] || {}).dup) #copy (dup) to preserve params because we manipulate params in the response_set methods
          if (saved && params[:finish])
            @response_set.complete!
            saved = @response_set.save!
          end
        end
      end
      respond_to do |format|
        format.html do
          if saved && params[:finish]
            flash[:notice] = t('surveyor.completed_survey')
            redirect_to surveyor_finish
          else
            flash[:notice] = t('surveyor.unable_to_update_survey') if !saved #and !saved.nil? # saved.nil? is true if there are no questions on the page (i.e. if it only contains a label)
            redirect_to :action => "edit", :anchor => anchor_from(params[:section]), :params => {:section => section_id_from(params[:section])}
          end
        end
        # No redirect needed if we're talking to the page via json
        format.js do
          render :json => @response_set.all_dependencies.to_json
        end
      end
    end

    private

    # Filters
    def get_current_user
      @current_user = self.respond_to?(:current_user) ? self.current_user : nil
    end

    # Params: the name of some submit buttons store the section we'd like to go to. for repeater questions, an anchor to the repeater group is also stored
    # e.g. params[:section] = {"1"=>{"question_group_1"=>"<= add row"}}
    def section_id_from(p)
      p.respond_to?(:keys) ? p.keys.first : p
    end

    def anchor_from(p)
      p.respond_to?(:keys) && p[p.keys.first].respond_to?(:keys) ? p[p.keys.first].keys.first : nil
    end

    def surveyor_index
      available_surveys_path
    end
    def surveyor_finish
      available_surveys_path
    end
  end
end