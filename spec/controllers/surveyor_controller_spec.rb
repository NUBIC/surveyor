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
    def do_get
      get :new
    end

    it "should render index template" do
      do_get
      response.should be_success
      response.should render_template('new')
    end

    it "should list codes and survey_versions for all surveys" do
      original = Factory(:survey, :title => "Foo", :access_code => 'foo')
      supplant = Factory(:survey, :title => "Foo", :access_code => 'foo', :survey_version => 1)
      hash = {"foo"=>{"title"=>"Foo", "survey_versions"=>[0, 1]}}
      do_get
      assigns(:codes).should eq hash
    end
  end

  describe "take survey: POST /surveys/xyz" do
    before(:each) do
      @survey = Factory(:survey, :title => "xyz", :access_code => "xyz")
      @newsurvey = Factory(:survey, :title => "xyz", :access_code => "xyz", :survey_version => 1)
      @response_set = Factory(:response_set, :access_code => "pdq")
      ResponseSet.stub!(:create).and_return(@response_set)
    end

    describe "with success" do
      def do_post
        post :create, :survey_code => "xyz"
      end
      it "should look for the latest survey_version of the survey if survey_version is not explicitely provided" do
        do_post
        assigns(:survey).should eq(@newsurvey)
      end
      
      it "should look for the partculer survey_version of the survey if it is provided" do
        post :create, :survey_code => "xyz", :survey_version => 0
        assigns(:survey).should eq(@survey)
      end
      
      it "should create a new response_set" do
        ResponseSet.should_receive(:create).and_return(@response_set)
        do_post
      end
      it "should redirect to the new response_set" do
        do_post
        response.should redirect_to(
          edit_my_survey_url(:survey_code => "xyz", :response_set_code  => "pdq"))
      end
    end

    describe "with failures" do
      it "should re-redirect to 'new' if ResponseSet failed create" do
        ResponseSet.should_receive(:create).and_return(false)
        post :create, :survey_code => "XYZ"
        response.should redirect_to(available_surveys_url)
      end
      it "should re-redirect to 'new' if Survey failed find" do
        post :create, :survey_code => "ABC"
        response.should redirect_to(available_surveys_url)
      end
    end

    describe "determining if javascript is enabled" do
      it "sets the user session to know that javascript is enabled" do
        post :create, :survey_code => "xyz", :surveyor_javascript_enabled => "true"
        session[:surveyor_javascript].should_not be_nil
        session[:surveyor_javascript].should == "enabled"
      end

      it "sets the user session to know that javascript is not enabled" do
        post :create, :survey_code => "xyz", :surveyor_javascript_enabled => "not_true"
        session[:surveyor_javascript].should_not be_nil
        session[:surveyor_javascript].should == "not_enabled"
      end

    end

  end

  describe "view my survey: GET /surveys/xyz/pdq" do
    before(:each) do
      @survey = Factory(:survey,
        :title => "xyz", :access_code => "xyz", :sections => [Factory(:survey_section)])
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
      ResponseSet.should_receive(:find_by_access_code).
        with("pdq",{:include=>{:responses=>[:question, :answer]}}).and_return(@response_set)
      do_get
    end

    it "should redirect if :response_code not found" do
      get :show, :survey_code => "xyz", :response_set_code => "DIFFERENT"
      response.should redirect_to(available_surveys_url)
    end
    
    it "should render correct survey survey_version" do
      supplant = Factory(:survey, :title => "xyz", :access_code => 'xyz', :survey_version => 1)
      supplant_section = Factory(:survey_section, :survey => supplant)
      supplant_response_set = Factory(:response_set, :access_code => "rst", :survey => supplant)
      
      get :show, :survey_code => "xyz", :response_set_code => "pdq"
      response.should be_success
      response.should render_template('show')
      assigns[:response_set].should == @response_set
      assigns[:survey].should == @survey
      
      get :show, :survey_code => "xyz", :response_set_code => "rst"
      response.should be_success
      response.should render_template('show')
      assigns[:response_set].should == supplant_response_set
      assigns[:survey].should == supplant
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

    it "should only set dependents if javascript is not enabled" do
      ResponseSet.should_receive(:find_by_access_code).and_return(@response_set)
      controller.stub!(:get_unanswered_dependencies_minus_section_questions).
        and_return([Question.new])

      get :edit, :survey_code => "XYZ", :response_set_code => "PDQ"
      assigns[:dependents].should_not be_empty
      session[:surveyor_javascript].should be_nil
    end

    it "should not set dependents if javascript is enabled" do
      ResponseSet.should_receive(:find_by_access_code).and_return(@response_set)
      controller.stub!(:get_unanswered_dependencies_minus_section_questions).
        and_return([Question.new])

      session[:surveyor_javascript] = "enabled"

      get :edit, :survey_code => "XYZ", :response_set_code => "PDQ"
      assigns[:dependents].should be_empty
      session[:surveyor_javascript].should == "enabled"
    end
    
    it "should render correct survey survey_version" do
      supplant = Factory(:survey, :title => "XYZ", :access_code => 'XYZ', :survey_version => 1)
      supplant_section = Factory(:survey_section, :survey => supplant)
      supplant_response_set = Factory(:response_set, :access_code => "RST", :survey => supplant)
      
      get :edit, :survey_code => "XYZ", :response_set_code => "PDQ"
      response.should be_success
      response.should render_template('edit')
      assigns[:response_set].should == @response_set
      assigns[:survey].should == @survey
      
      get :edit, :survey_code => "XYZ", :response_set_code => "RST"
      response.should be_success
      response.should render_template('edit')
      assigns[:response_set].should == supplant_response_set
      assigns[:survey].should == supplant
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
         "6"=>{"question_id"=>"6", "answer_id" => "6", "string_value"=>"saf"}, #string
         "7"=>{"question_id"=>"7", "answer_id" => "11", "text_value"=>"foo"}, #text
         "1"=>{"question_id"=>"1", "answer_id"=>"1", "string_value"=>"bar"}, #radio+txt
         "2"=>{"question_id"=>"2", "answer_id"=>"6"}, #radio
         "3"=>{"question_id"=>"3", "answer_id"=>"10"}, #radio
         "4"=>{"question_id"=>"4", "answer_id"=>"15"}, #check
         "5"=>{"question_id"=>"5", "answer_id"=>"16", "string_value"=>""} #check+txt
      }
      put :update, :survey_code => "XYZ", :response_set_code => "PDQ", :finish => "finish", :r => responses
    end

    it "should find the response set requested" do
      ResponseSet.should_receive(:find_by_access_code).and_return(@response_set)
      do_put
    end

    it "should redirect to 'edit' without params" do
      do_put
      response.should redirect_to(:action => :edit)
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

  describe "update my survey with ajax" do
    before(:each) do
      @survey = Factory(:survey, :title => "XYZ", :access_code => "XYZ")
      @section = Factory(:survey_section, :survey => @survey)
      @response_set = Factory(:response_set, :access_code => "PDQ", :survey => @survey)
      ResponseSet.stub!(:find_by_access_code).and_return(@response_set)
    end

    def do_ajax_put(r)
      xhr :put, :update, :survey_code => "XYZ", :response_set_code => "PDQ", :r => r
    end

    it "should return an id for new responses" do
      do_ajax_put({
         "2"=>{"question_id"=>"4", "answer_id"=>"14"}
      })
      JSON.parse(response.body).
        should == {"ids" => {"2" => 1}, "remove" => {}, "show" => [], "hide" => []}
      do_ajax_put({
         "4"=>{"question_id"=>"4", "answer_id"=>"15"}
      })
      JSON.parse(response.body).
        should == {"ids" => {"4" => 2}, "remove" => {}, "show" => [], "hide" => []}
    end

    it "should return a delete for when responses are removed" do
      r = @response_set.responses.create(:question_id => 4, :answer_id => 14)
      do_ajax_put({
         "2"=>{"question_id"=>"4", "answer_id"=>"", "id" => r.id} # uncheck
      })
      # r.id is a String with AR 3.0 and an int with AR 3.1
      JSON.parse(response.body)['remove']['2'].to_s.should == r.id.to_s
    end

    it "should return dependencies" do
      @response_set.should_receive(:all_dependencies).
        and_return({"show" => ['q_1'], "hide" => ['q_2']})
      do_ajax_put({
        "4"=>{"question_id"=>"9", "answer_id"=>"12"} #check
      })
      JSON.parse(response.body).
        should == {"ids" => {"4" => 1}, "remove" => {}, "show" => ['q_1'], "hide" => ["q_2"]}
    end
  end
end
