# The Surveying controller handles the process of a user taking a survey.
# It is semi-restful since it does not have a concrete representation model.
# The "resource" could be considered a survey attempt or survey session.
# It is actually the union of a user filling out a survey and populating a response set.

class SurveyingController < ApplicationController
  unloadable # http://dev.rubyonrails.org/ticket/6001#comment:12

  layout Surveyor::Config['default.layout'] || 'surveyor_default'
  include SurveyingHelper
  before_filter :get_response_set, :except => [:new, :create]

  def index
    @surveys = Survey.find(:all) 
  end

  def new
    @current_user = self.respond_to?(:current_user) ? self.current_user : nil
    @surveys = Survey.find(:all)
    respond_to do |format|
      format.html # new.html.erb
      # format.xml  { render :xml => @surveys }
    end
  end

  def create
    @survey = Survey.find_by_access_code(params[:survey_code])
    unless @survey
      flash[:notice] = "Unable to find that survey"
      redirect_to(available_surveys_path)
    else
      @response_set = ResponseSet.new(:survey => @survey, :user_id => 123)
      respond_to do |format|
        if @response_set.save!
          flash[:notice] = 'Survey was successfully created.'
          format.html { redirect_to(edit_my_survey_path(:survey_code => @survey.access_code, :response_set_code  => @response_set.access_code)) }
          # format.xml  { render :xml => @response_set, :status => :created, :location => @response_set }
        else
          format.html { redirect_to(available_surveys_path)}
          # format.xml  { render :xml => @response_set.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      # format.xml  { render :xml => @survey}
    end
  end

  def edit
    # Checking from the questions on the page (which are in the response hash) if there are any dependent questions to show
    dependent_hash = dependents(@response_set)
    @dependents = dependent_hash[:show]
    respond_to do |format|
      format.html do
        render
      end
      format.json do
        render :json => {:show => dependent_hash[:show].map{|q| question_id_helper(q)}, :hide => dependent_hash[:hide].map{|q| question_id_helper(q)} }.to_json
      end
    end
  end

  def update
    finished = false
    if params[:responses] or params[:response_groups]
      saved = @response_set.update_attributes(:response_attributes => (params[:responses] || {}).dup , :response_group_attributes => (params[:response_groups] || {}).dup) #copy (dup) to preserve params because we manipulate params in the response_set methods
      if (saved && params[:finish])
        @response_set.complete!
        saved = @response_set.save!
        finished = true
      end
    end
    respond_to do |format|
      format.html do
        if (finished && saved)
          flash[:notice] = "Completed survey"
          redirect_to surveyor_default_finish
        else
          flash[:notice] = "Unable to update survey" if !saved and !saved.nil? # saved.nil? is true if there are no questions on the page (i.e. if it only contains a label)
          redirect_to :action => "edit", :anchor => @anchor, :params => {:section => @section.id}
        end
      end
      # No redirect needed if we're talking to the page via json
      format.js do
        dependent_hash = dependents(@response_set)
        @dependents = dependent_hash[:show]
        render :json => {:show => dependent_hash[:show].map{|q| question_id_helper(q)}, :hide => dependent_hash[:hide].map{|q| question_id_helper(q)} }.to_json
      end
    end
  end

  private
  
  # Returns the dependent questions that need to be answered based on the current progress of the response set
  # it also returns the dependent questions that need to be hidden
  def dependents(response_set)
    show = []
    hide = []
    question_ids = response_set.responses.map(&:question_id).uniq # returning a list of all answered questions (only the ids)
    dependencies = DependencyCondition.find_all_by_question_id(question_ids).map(&:dependency).uniq
    dependencies.each do |dep|
      if dep.met?(response_set) # and response_set.has_not_answered_question?(dep.question)
        show << dep.question
      else
        hide << dep.question
      end
    end
    {:show => show, :hide => hide}
  end

  protected

  def get_response_set
    @response_set = ResponseSet.find_by_access_code(params[:response_set_code])
    if @response_set 
      @survey = @response_set.survey
      found = nil
      @anchor = nil
      unless params[:section].nil?
        # The section to display is passed to us either in the url of a GET request or form params in a POST request
        # Defaulting to look at the posted form params first, then as a url param.
        section_id = (params[:section].respond_to?(:keys))? params[:section].keys.first.split("_").first.to_i : params[:section]
        found = @survey.sections.find_by_id(section_id)
        @anchor = (params[:section].respond_to?(:keys) and params[:section].keys.first.split("_").size > 1)? params[:section].keys.first.split("_").last : nil

      end

      @section = found || @survey.sections.first
      @dependents = []
    else
      flash[:notice] = "Unable to find your responses to the survey"
      redirect_to(available_surveys_path)
    end
  end

end
