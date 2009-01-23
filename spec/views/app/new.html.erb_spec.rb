require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/surveys/new.html.erb" do
  include AppHelper
  
  before(:each) do
    @survey = mock_model(Survey)
    @survey.stub!(:new_record?).and_return(true)
    assigns[:survey] = @survey
  end

  it "should render new form" do
    pending
    render "/surveys/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", surveys_path) do
    end
  end
end


