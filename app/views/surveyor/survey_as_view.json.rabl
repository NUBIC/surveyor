object @response_set

attribute :access_code => :response_access_code

child :survey do
  attribute :title
  attribute :access_code => :survey_access_code
  child :sections do
    attribute :title
    child :questions do
      attributes :text, :id, :question_group
      child :question_group do
        attributes :text
      end
    end
  end
end