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
    let(:survey_code) { 'XYZ' }
    let!(:survey) { Factory(:survey, :title => survey_code, :access_code => survey_code) }

    let(:response_set_code) { 'PDQ' }
    let!(:response_set) { Factory(:response_set, :access_code => response_set_code, :survey => survey) }

    let(:responses_ui_hash) { {} }

    let(:params) {
      {
        :survey_code => survey_code,
        :response_set_code => response_set_code,
        :r => responses_ui_hash.empty? ? nil : responses_ui_hash
      }
    }

    def a_ui_response(hash)
      { 'api_id' => 'something' }.merge(hash)
    end

    shared_examples 'common update behaviors' do
      it "should find the response set requested" do
        ResponseSet.should_receive(:find_by_access_code).and_return(response_set)
        do_put
      end

      it 'applies any provided responses to the response set' do
        ResponseSet.stub!(:find_by_access_code).and_return(response_set)

        responses_ui_hash['11'] = a_ui_response('answer_id' => '56', 'question_id' => '9')
        response_set.should_receive(:update_from_ui_hash).with(responses_ui_hash)
        do_put
      end

      it 'does not fail when there are no responses' do
        lambda { do_put }.should_not raise_error
      end

      describe 'when updating the response set produces a constraint violation' do
        it 'retries the update'

        it 'only retries three times'
      end
    end

    describe 'via full cycle form submission' do
      def do_put
        put :update, params
      end

      include_examples 'common update behaviors'

      it "should redirect to 'edit' without params" do
        do_put
        response.should redirect_to(:action => :edit)
      end

      describe 'on finish' do
        before do
          params[:finish] = 'finish'
          do_put
        end

        it "completes the found response set" do
          response_set.reload.should be_complete
        end

        it 'flashes completion' do
          flash[:notice].should == "Completed survey"
        end
      end

      it "should redirect to available surveys if :response_code not found" do
        params[:response_set_code] = "DIFFERENT"
        do_put
        response.should redirect_to(available_surveys_url)
        flash[:notice].should == "Unable to find your responses to the survey"
      end
    end

    describe 'via ajax' do
      def do_put
        xhr :put, :update, params
      end

      include_examples 'common update behaviors'

      it "should return dependencies" do
        ResponseSet.stub!(:find_by_access_code).and_return(response_set)

        response_set.should_receive(:all_dependencies).
          and_return({"show" => ['q_1'], "hide" => ['q_2']})

        responses_ui_hash['4'] = a_ui_response("question_id"=>"9", "answer_id"=>"12") # check
        do_put

        JSON.parse(response.body).
          should == {"show" => ['q_1'], "hide" => ["q_2"]}
      end

      it '404s if the response set does not exist' do
        params[:response_set_code] = 'ELSE'
        do_put
        response.status.should == 404
      end
    end
  end
end
