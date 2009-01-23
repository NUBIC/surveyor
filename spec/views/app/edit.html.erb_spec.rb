require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/surveys/edit.html.erb" do
  include AppHelper
  
  before do
    @survey = mock_model(Survey)
    assigns[:survey] = @survey
  end

  it "should render edit form" do
    pending
    render "/surveys/edit.html.erb"
    
    response.should have_tag("form[action=#{survey_path(@survey)}][method=post]") do
    end
  end
end


