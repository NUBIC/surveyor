object @response_set

attribute :access_code => :response_access_code

child @response_set.responses do |response|
  attributes :question_id, :datetime_value, :integer_value, :float_value, :unit, :text_value, :string_value, :response_other, :pick
  child :answer do
    attributes :text
  end
end
