require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../lib/surveyor/helpers/formtastic_custom_input')

describe Surveyor::Helpers::FormtasticCustomInput do
  context "input helpers" do
    it "should translate response class into attribute" do
      helper.response_class_to_method(:string).should == :string_value
      helper.response_class_to_method(:integer).should == :integer_value
      helper.response_class_to_method(:float).should == :float_value
      helper.response_class_to_method(:datetime).should == :datetime_value
      helper.response_class_to_method(:date).should == :date_value
      helper.response_class_to_method(:time).should == :time_value
    end
  end
end