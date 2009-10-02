require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SurveyorController do
  
  # map.available_surveys 'surveys',                                        :conditions => {:method => :get}, :action => "new"      # GET survey list
  # map.take_survey       'surveys/:survey_code',                           :conditions => {:method => :post}, :action => "create"  # Only POST of survey to create
  # map.view_my_survey    'surveys/:survey_code/:response_set_code',        :conditions => {:method => :get}, :action => "show"     # GET viewable/printable? survey
  # map.edit_my_survey    'surveys/:survey_code/:response_set_code/take',   :conditions => {:method => :get}, :action => "edit"     # GET editable survey 
  # map.update_my_survey  'surveys/:survey_code/:response_set_code',        :conditions => {:method => :put}, :action => "update"   # PUT edited survey 
  # map.finish_my_survey  'surveys/:survey_code/:response_set_code/finish', :conditions => {:method => :put}, :action => "finish"   # PUT to close out the response_set
  
  describe "handling GET /surveys (available_surveys)" do

    before(:each) do
      @survey = mock_model(Survey)
      Survey.stub!(:find).and_return([@survey])
    end
  
    def do_get
      get :new
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
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

  describe "handling GET /surveys.xml (available_surveys)" do
    before(:each) do
      @surveys = mock("Array of Surveys", :to_xml => "XML")
      Survey.stub!(:find).and_return(@surveys)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :new
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all surveys" do
      Survey.should_receive(:find).with(:all).and_return(@surveys)
      do_get
    end
  
    it "should render the found surveys as xml" do
      @surveys.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling POST /surveys/XYZ (take_survey)" do

    before(:each) do
      @survey = mock_model(Survey, :access_code => "XYZ")
      @response_set = mock_model(ResponseSet, :access_code => "PDQ")
      ResponseSet.stub!(:new).and_return(@response_set)
      Survey.stub!(:find_by_access_code).and_return(@survey)
    end
    
    describe "with successful save" do
  
      def do_post
        @response_set.should_receive(:save!).and_return(true)
        post :create, :survey_code => "XYZ"
      end
      
      it "should look for the survey" do
        Survey.should_receive(:find_by_access_code).with("XYZ").and_return(@survey)
        do_post
      end
      it "should create a new response_set" do
        ResponseSet.should_receive(:new).and_return(@response_set)
        do_post
      end

      it "should redirect to the new response_set" do
        do_post
        response.should redirect_to(edit_my_survey_url(:survey_code => "XYZ", :response_set_code  => "PDQ"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @response_set.should_receive(:save!).and_return(false)
        post :create, :survey_code => "XYZ"
      end
  
      it "should re-redirect to 'new'" do
        do_post
        response.should redirect_to(available_surveys_url)
      end
      
    end
    
    describe "with survey not found" do

      def do_post
        Survey.should_receive(:find_by_access_code).and_return(nil)
        post :create, :survey_code => "XYZ"
      end
  
      it "should re-redirect to 'new'" do
        do_post
        response.should redirect_to(available_surveys_url)
      end
      
    end
  end

  describe "handling GET /surveys/XYZ/PDQ (view_my_survey)" do

    before(:each) do
      @survey = mock_model(Survey, :access_code => "XYZ", :sections => [mock_model(SurveySection)])  
      @response_set = mock_model(ResponseSet, :access_code => "PDQ")
      ResponseSet.stub!(:find_by_access_code).with("PDQ").and_return(@response_set)
      @response_set.stub!(:survey).and_return(@survey)
    end
  
    def do_get
      get :show, :survey_code => "XYZ", :response_set_code => "PDQ"
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
      ResponseSet.should_receive(:find_by_access_code).with("PDQ").and_return(@response_set)
      do_get
    end
  
    it "should assign the found response_set and survey for the view" do
      do_get
      assigns[:response_set].should equal(@response_set)
      assigns[:survey].should equal(@survey)
    end
    
    it "should redirect if :response_code not found" do
      get :show, :survey_code => "XYZ", :response_set_code => "DIFFERENT"
      response.should redirect_to(available_surveys_url)      
    end
    
    # I'm not sure this is enterly neccessary since we look up the survey from the response_code in the url -BC
    it "should redirect if :survey_code in url doesn't match response_set.survey.access_code" do
      pending
      get :show, :survey_code => "DIFFERENT", :response_set_code => "PDQ"
      response.should redirect_to(available_surveys_url)
    end
  end

  describe "handling GET /surveys/XYZ/PDQ/take (edit_my_survey)" do

    before(:each) do
      @survey = mock_model(Survey, :access_code => "XYZ")
      @survey_section = mock_model(SurveySection)
      @survey.stub!(:sections).and_return([@survey_section])
      @response_set = mock_model(ResponseSet, :access_code => "PDQ")
      ResponseSet.stub!(:find_by_access_code).with("PDQ").and_return(@response_set)     
      @response_set.stub!(:survey).and_return(@survey)
    end

    it "should be successful, render edit with the requested survey" do
      ResponseSet.should_receive(:find_by_access_code).with("PDQ").and_return(@response_set)
        
      get :edit, :survey_code => "XYZ", :response_set_code => "PDQ"
      response.should be_success
      response.should render_template('edit')
      assigns[:response_set].should equal(@response_set)
      assigns[:survey].should equal(@survey)
    end
    
    it "should redirect if :response_code not found" do
      get :edit, :survey_code => "XYZ", :response_set_code => "DIFFERENT"
      response.should redirect_to(available_surveys_url)      
    end

  end

  describe "handling PUT /surveys/XYZ/PDQ (update_my_survey)" do

    before(:each) do
      @survey = mock_model(Survey, :access_code => "XYZ", :sections => [mock_model(SurveySection)])
      @response_set = mock_model(ResponseSet, :access_code => "PDQ")
      ResponseSet.stub!(:find_by_access_code).with("PDQ").and_return(@response_set)
      @response_set.stub!(:survey).and_return(@survey)
      @response_set.stub!(:add_responses).and_return(true)
    end
    
    describe "with no response_set in update" do

      it "should find the response set requested" do
        ResponseSet.should_receive(:find_by_access_code).with("PDQ").and_return(@response_set)
        put :update, :survey_code => "XYZ", :response_set_code => "PDQ"
        
      end
    
    end
    
    describe "with a new response set" do
      
      it "should accept properly formatted params and save the data" do
        response_set_params = {"survey_code"=>"XYZ", "response_set"=>{"new_response_attributes"=>{"1"=>[{"answer_id"=>"2"}]}}}
        
        
      end
      
      # describe "issue with posting data to an existing survey and the data not saving properly" do
      #    @survey = mock_model(Survey, :access_code => "XYZ")
      #    @response_set = mock_model(ResponseSet, :access_code => "PDQ")
      #    ResponseSet.stub!(:find_by_access_code).with("PDQ").and_return(@response_set)
      #    @response_set.stub!(:survey).and_return(@survey)
      #    @response_set.stub!(:complete!).and_return(Time.now)
      #    
      #    
      #  end

      # first post {"survey_code"=>"test_survey", "commit"=>"Next Section (Utensiles and you!) >>", "response_set"=>{"new_response_attributes"=>{"1"=>[{"answer_id"=>"2"}, {"answer_id"=>"0", "string_value"=>""}], "2"=>[{"answer_id"=>"6"}], "3"=>[{"answer_id"=>"10"}], "4"=>[{"answer_id"=>"14"}], "5"=>[{"answer_id"=>"0"}, {"answer_id"=>"0"}]}, "existing_response_attributes"=>{"6"=>{"1"=>{"answer_id"=>"20", "string_value"=>"B"}}, "7"=>{"2"=>{"text_value"=>"foo", "answer_id"=>"21"}}, "5"=>{"7"=>{"answer_id"=>"17"}, "16"=>{"answer_id"=>"19", "string_value"=>"blah"}}}}, "authenticity_token"=>"d9ba68fe20a46703f3737b5cb0b7e17b7390de32", "_method"=>"put", "action"=>"update", "controller"=>"app", "response_set_code"=>"9VEsec1dK6", "section"=>"2"}
      # second post {"survey_code"=>"test_survey", "commit"=>"Next Section (Utensiles and you!) >>", "response_set"=>{"new_response_attributes"=>{"1"=>[{"answer_id"=>"2"}, {"answer_id"=>"0", "string_value"=>""}], "2"=>[{"answer_id"=>"6"}], "3"=>[{"answer_id"=>"10"}], "4"=>[{"answer_id"=>"14"}], "5"=>[{"answer_id"=>"0"}, {"answer_id"=>"0"}]}, "existing_response_attributes"=>{"6"=>{"1"=>{"answer_id"=>"20", "string_value"=>"B"}}, "7"=>{"2"=>{"text_value"=>"boooo", "answer_id"=>"21"}}, "5"=>{"7"=>{"answer_id"=>"17"}, "16"=>{"answer_id"=>"19", "string_value"=>"blahblahstink"}}}}, "authenticity_token"=>"d9ba68fe20a46703f3737b5cb0b7e17b7390de32", "_method"=>"put", "action"=>"update", "controller"=>"app", "response_set_code"=>"9VEsec1dK6", "section"=>"2"}

      
    end
    
    
    describe "with failed update" do

      it "should re-render 'edit'" do
        put :update, :survey_code => "XYZ", :response_set_code => "PDQ"
        response.should be_success
        response.should render_template('edit')
        flash[:notice].should == "Unable to update survey"
      end

    end
  end

  describe "handling PUT /surveys/XYZ/PDQ/finish (finish_my_survey)" do

    before(:each) do
      @survey = mock_model(Survey, :access_code => "XYZ", :sections => [mock_model(SurveySection)])
      @response_set = mock_model(ResponseSet, :access_code => "PDQ")
      ResponseSet.stub!(:find_by_access_code).with("PDQ").and_return(@response_set)
      @response_set.stub!(:survey).and_return(@survey)
      @response_set.stub!(:complete!).and_return(Time.now)
    end
    
    describe "with successful update" do

      def do_put
        put :finish, :survey_code => "XYZ", :response_set_code => "PDQ"
      end

      it "should find the response_set requested" do
        ResponseSet.should_receive(:find_by_access_code).with("PDQ").and_return(@response_set)
        do_put
      end

      it "should update the found response set" do
        @response_set.should_receive(:complete!).and_return(Time.now)
        do_put
      end

      it "should assign the found response set and survey for the view" do
        do_put
        assigns(:response_set).should equal(@response_set)
        assigns(:survey).should equal(@response_set.survey)
      end

      it "should render the 'edit' template" do
        do_put
        response.should render_template('edit')
        flash[:notice].should == "Completed survey"
      end
      
      it "should redirect to available surveys if :response_code not found" do
        put :update, :survey_code => "XYZ", :response_set_code => "DIFFERENT"
        response.should redirect_to(available_surveys_url)
        flash[:notice].should == "Unable to find your responses to the survey"
      end

    end
    
    describe "with failed update" do

      def do_put
        put :finish, :survey_code => "XYZ", :response_set_code => "PDQ"
      end

      it "should re-render 'edit'" do
        @response_set.should_receive(:complete!).and_return(false)
        do_put
        response.should render_template('edit')
        flash[:notice].should == "Unable to complete survey"
      end

    end
  end
  

end
