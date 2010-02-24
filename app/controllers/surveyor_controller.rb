# The Surveyor controller a user taking a survey. It is semi-RESTful since it does not have a concrete representation model.
# The "resource" is a survey attempt/session populating a response set.

class SurveyorController < ApplicationController
  
  # Layout
  layout Surveyor::Config['default.layout'] || 'surveyor_default'
  
  # Extending surveyor
  include SurveyorControllerExtensions if Surveyor::Config['extend_controller']
  before_filter :extend_actions
  
  # RESTful authentication
  if Surveyor::Config['use_restful_authentication']
    include AuthenticatedSystem
    before_filter :login_required
  end
  
  # Get the response set or current_user
  # before_filter :get_response_set, :except => [:new, :create]
  before_filter :get_current_user, :only => [:new, :create]
  
  # Actions
  def new
    @surveys = Survey.find(:all)
    redirect_to surveyor_default(:index) unless available_surveys_path == surveyor_default(:index)
  end

  def create
    if (@survey = Survey.find_by_access_code(params[:survey_code])) && (@response_set = ResponseSet.create(:survey => @survey, :user_id => (@current_user.nil? ? @current_user : @current_user.id)))
      flash[:notice] = "Survey was successfully started."
      redirect_to(edit_my_survey_path(:survey_code => @survey.access_code, :response_set_code  => @response_set.access_code))
    else
      flash[:notice] = "Unable to find that survey"
      redirect_to(available_surveys_path)
    end
  end

  def show
  end
  
  def edit
    if @response_set = ResponseSet.find_by_access_code(params[:response_set_code], :include => {:responses => [:question, :answer]})
      @survey = Survey.with_sections.find_by_id(@response_set.survey_id)
      @sections = @survey.sections
      @section = params[:section] ? @sections.with_includes.find(section_id_from(params[:section])) || @sections.with_includes.first : @sections.with_includes.first
      @questions = @section.questions
      @dependents = (@response_set.unanswered_dependencies - @section.questions) || []
    else
      flash[:notice] = "Unable to find your responses to the survey"
      redirect_to(available_surveys_path)
    end
  end
  
  def update
    if @response_set = ResponseSet.find_by_access_code(params[:response_set_code], :include => {:responses => :answer})
      @response_set.current_section_id = params[:current_section_id]
    else
      flash[:notice] = "Unable to find your responses to the survey"
      redirect_to(available_surveys_path) and return
    end
    
    if params[:responses] or params[:response_groups]
      @response_set.clear_responses
      saved = @response_set.update_attributes(:response_attributes => (params[:responses] || {}).dup , :response_group_attributes => (params[:response_groups] || {}).dup) #copy (dup) to preserve params because we manipulate params in the response_set methods
      if (saved && params[:finish])
        @response_set.complete!
        saved = @response_set.save!
      end
    end
    respond_to do |format|
      format.html do
        if saved && params[:finish]
          flash[:notice] = "Completed survey"
          redirect_to surveyor_default(:finish)
        else
          flash[:notice] = "Unable to update survey" if !saved #and !saved.nil? # saved.nil? is true if there are no questions on the page (i.e. if it only contains a label)
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
  
  # Extending surveyor
  def surveyor_default(type = :finish)
    # http://www.postal-code.com/mrhappy/blog/2007/02/01/ruby-comparing-an-objects-class-in-a-case-statement/
    # http://www.skorks.com/2009/08/how-a-ruby-case-statement-works-and-what-you-can-do-with-it/
    case arg = Surveyor::Config["default.#{type.to_s}"]
    when String
      return arg
    when Symbol
      return self.send(arg)
    else
      return available_surveys_path
    end
  end
  
  def extend_actions
    # http://blog.mattwynne.net/2009/07/11/rails-tip-use-polymorphism-to-extend-your-controllers-at-runtime/
    self.extend SurveyorControllerExtensions::Actions if Surveyor::Config['extend_controller'] && defined? SurveyorControllerExtensions::Actions
  end

end
