object @response_set

attribute :access_code => :response_access_code

child :survey do
  attribute :title
  attribute :access_code => :survey_access_code
  child :sections do
    attribute :title
    child :questions do
      attributes :text, :id, :api_id
      child :answers do
        attributes :text, :id, :api_id
      end
    end
  end
end