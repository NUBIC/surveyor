require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    @user = User.new
  end

  it "should be valid" do
    @user.should be_valid
  end
end
