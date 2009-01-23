require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/surveys/index.html.erb" do
  include AppHelper
  
  before(:each) do
    survey_98 = mock_model(Survey)
    survey_99 = mock_model(Survey)

    assigns[:surveys] = [survey_98, survey_99]
  end

  it "should render list of surveys" do
    
      pending
    render "/surveys/index.html.erb"
  end
end

