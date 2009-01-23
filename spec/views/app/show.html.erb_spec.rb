require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/surveys/show.html.erb" do
  include AppHelper
  
  before(:each) do
    @survey = mock_model(Survey)

    assigns[:survey] = @survey
  end

  it "should render attributes in <p>" do
    pending
    render "/surveys/show.html.erb"
  end
end

