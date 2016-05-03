object @survey

attribute :title
attribute :access_code => :survey_access_code
child :sections do
  attribute :title
  child :questions do
    attributes :text, :id, :api_id, :pick
    child :answers do
      attributes :text, :id, :api_id
    end
  end
end