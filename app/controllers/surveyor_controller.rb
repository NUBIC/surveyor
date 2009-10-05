# The Surveyor controller handles the process of a user taking a survey.
# It is semi-restful since it does not have a concrete representation model.
# The "resource" could be considered a survey attempt or survey session.
# It is actually the union of a user filling out a survey and populating a response set.

class SurveyorController < ApplicationController
  # unloadable # http://dev.rubyonrails.org/ticket/6001#comment:12
  
  # Layout
  layout Surveyor::Config['default.layout'] || 'surveyor_default'
  
  # Extend controller and actions
  include SurveyorControllerExtensions if Surveyor::Config['extend_controller'] && defined? SurveyorControllerExtensions
  before_filter :extend_actions
  
  # Restful authentication
  if Surveyor::Config['use_restful_authentication']
    include AuthenticatedSystem
    before_filter :login_required
  end
  
  # Get the response set
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
    @current_user = self.respond_to?(:current_user) ? self.current_user : nil
    @survey = Survey.find_by_access_code(params[:survey_code])
    unless @survey
      flash[:notice] = "Unable to find that survey"
      redirect_to(available_surveys_path)
    else
      @response_set = ResponseSet.new(:survey => @survey, :user_id => @current_user)
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
    respond_to do |format|
      format.html do
        # with js turned off - show unanswered dependencies, but if they are questions on the current page, don't show them twice
        @dependents = @response_set.unanswered_dependencies - @section.questions
        render
      end
      format.json do
        dependent_hash = @response_set.all_dependencies
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
        dependent_hash = @response_set.all_dependencies
        render :json => {:show => dependent_hash[:show].map{|q| question_id_helper(q)}, :hide => dependent_hash[:hide].map{|q| question_id_helper(q)} }.to_json
      end
    end
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

  def surveyor_default_finish
    # http://www.postal-code.com/mrhappy/blog/2007/02/01/ruby-comparing-an-objects-class-in-a-case-statement/
    # http://www.skorks.com/2009/08/how-a-ruby-case-statement-works-and-what-you-can-do-with-it/
    case finish = Surveyor::Config['default.finish']
    when String
      return finish
    when Symbol
      return self.send(finish)
    when Proc
      return finish.call
    else
      return '/surveys'
    end
  end
  
  private
  
  def extend_actions
    # http://blog.mattwynne.net/2009/07/11/rails-tip-use-polymorphism-to-extend-your-controllers-at-runtime/
    self.extend SurveyorControllerExtensions::Actions if Surveyor::Config['extend_controller'] && defined? SurveyorControllerExtensions::Actions
  end

end
