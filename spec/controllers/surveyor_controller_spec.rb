require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SurveyorController do
  
  # map.with_options :controller => 'surveyor' do |s|
  #   s.available_surveys "#{root}",                                       :conditions => {:method => :get}, :action => "new"      # GET survey list
  #   s.take_survey       "#{root}:survey_code",                           :conditions => {:method => :post}, :action => "create"  # Only POST of survey to create
  #   s.view_my_survey    "#{root}:survey_code/:response_set_code",        :conditions => {:method => :get}, :action => "show"     # GET viewable/printable? survey
  #   s.edit_my_survey    "#{root}:survey_code/:response_set_code/take",   :conditions => {:method => :get}, :action => "edit"     # GET editable survey 
  #   s.update_my_survey  "#{root}:survey_code/:response_set_code",        :conditions => {:method => :put}, :action => "update"   # PUT edited survey 
  # end   
  
  describe "available surveys: GET /surveys" do

    before(:each) do
      @survey = Factory(:survey)
      Survey.stub!(:find).and_return([@survey])
    end
  
    def do_get
      get :new
    end
  
    it "should render index template" do
      do_get
      response.should be_success
      response.should render_template('new')
    end

    it "should find all surveys" do
      Survey.should_receive(:find).with(:all).and_return([@survey])
      do_get
    end
    
    it "should assign the found surveys for the view" do
      do_get
      assigns[:surveys].should == [@survey]
    end
  end

  describe "take survey: POST /surveys/xyz" do

    before(:each) do
      @survey = Factory(:survey, :title => "xyz", :access_code => "xyz")
      @response_set = Factory(:response_set, :access_code => "pdq")
      ResponseSet.stub!(:create).and_return(@response_set)
      Survey.stub!(:find_by_access_code).and_return(@survey)
    end
    
    describe "with success" do
      def do_post
        post :create, :survey_code => "xyz"
      end
      it "should look for the survey" do
        Survey.should_receive(:find_by_access_code).with("xyz").and_return(@survey)
        do_post
      end
      it "should create a new response_set" do
        ResponseSet.should_receive(:create).and_return(@response_set)
        do_post
      end
      it "should redirect to the new response_set" do
        do_post
        response.should redirect_to(edit_my_survey_url(:survey_code => "xyz", :response_set_code  => "pdq"))
      end
    end
    
    describe "with failures" do
      it "should re-redirect to 'new' if ResponseSet failed create" do
        ResponseSet.should_receive(:create).and_return(false)
        post :create, :survey_code => "XYZ"
        response.should redirect_to(available_surveys_url)
      end
      it "should re-redirect to 'new' if Survey failed find" do
        Survey.should_receive(:find_by_access_code).and_return(nil)
        post :create, :survey_code => "XYZ"
        response.should redirect_to(available_surveys_url)
      end
    end
  end

  describe "view my survey: GET /surveys/xyz/pdq" do
   #integrate_views
    before(:each) do
      @survey = Factory(:survey, :title => "xyz", :access_code => "xyz", :sections => [Factory(:survey_section)])  
      @response_set = Factory(:response_set, :access_code => "pdq", :survey => @survey)
    end
  
    def do_get
      get :show, :survey_code => "xyz", :response_set_code => "pdq"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
    
    it "should render show template" do
      do_get
      response.should render_template('show')
    end
   
    it "should find the response_set requested" do
      ResponseSet.should_receive(:find_by_access_code).with("pdq",{:include=>{:responses=>[:question, :answer]}}).and_return(@response_set)
      do_get
    end

    it "should redirect if :response_code not found" do
      get :show, :survey_code => "xyz", :response_set_code => "DIFFERENT"
      response.should redirect_to(available_surveys_url)      
    end

  end

  describe "edit my survey: GET /surveys/XYZ/PDQ/take" do

    before(:each) do
      @survey = Factory(:survey, :title => "XYZ", :access_code => "XYZ")
      @section = Factory(:survey_section, :survey => @survey)      
      @response_set = Factory(:response_set, :access_code => "PDQ", :survey => @survey)
    end

    it "should be successful, render edit with the requested survey" do
      ResponseSet.should_receive(:find_by_access_code).and_return(@response_set)
      get :edit, :survey_code => "XYZ", :response_set_code => "PDQ"
      response.should be_success
      response.should render_template('edit')
      assigns[:response_set].should == @response_set
      assigns[:survey].should == @survey
    end
    it "should redirect if :response_code not found" do
      get :edit, :survey_code => "XYZ", :response_set_code => "DIFFERENT"
      response.should redirect_to(available_surveys_url)      
    end

  end

  describe "update my survey: PUT /surveys/XYZ/PDQ" do

    before(:each) do
      @survey = Factory(:survey, :title => "XYZ", :access_code => "XYZ")
      @section = Factory(:survey_section, :survey => @survey)      
      @response_set = Factory(:response_set, :access_code => "PDQ", :survey => @survey)
      # @response_set.stub!(:update_attributes).and_return(true)
      # @response_set.stub!(:complete!).and_return(Time.now)
      # @response_set.stub!(:save).and_return(true)
    end
    
    def do_put
      put :update, :survey_code => "XYZ", :response_set_code => "PDQ"
    end
    def do_put_with_finish
      responses = {
         "6"=>{"question_id"=>"6", "20"=>{"string_value"=>"saf"}}, #string
         "7"=>{"question_id"=>"7", "21"=>{"text_value"=>""}}, #text
         "1"=>{"question_id"=>"1", "answer_id"=>"1", "4"=>{"string_value"=>""}}, #radio+txt
         "2"=>{"answer_id"=>"6"}, #radio
         "3"=>{"answer_id"=>"10"}, #radio
         "4"=>{"question_id"=>"4", "answer_id"=>"15"}, #check
         "5"=>{"question_id"=>"5", "16"=>{"selected"=>"1"}, "19"=>{"string_value"=>""}} #check+txt
      }
      put :update, :survey_code => "XYZ", :response_set_code => "PDQ", :finish => "finish", :responses => responses
    end
    
    it "should find the response set requested" do
      ResponseSet.should_receive(:find_by_access_code).and_return(@response_set)
      do_put
    end
    it "should redirect to 'edit' without params" do
      do_put
      response.should redirect_to(:action => :edit)
      flash[:notice].should == "Unable to update survey"
    end
    it "should complete the found response set on finish" do      
      do_put_with_finish
      flash[:notice].should == "Completed survey"
    end
    it "should redirect to available surveys if :response_code not found" do
      put :update, :survey_code => "XYZ", :response_set_code => "DIFFERENT"
      response.should redirect_to(available_surveys_url)
      flash[:notice].should == "Unable to find your responses to the survey"
    end

  end
end
