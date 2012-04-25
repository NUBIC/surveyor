object @response_set
attribute :api_id => :uuid
attribute :created_at
attribute :completed_at
node(:survey_id){|rs| rs.survey.api_id }

child :responses do
  attribute :api_id => :uuid
  attribute :created_at
  attribute :updated_at => :modified_at
  node(:answer_id){|r| r.answer.api_id }
  node(:question_id){|r| r.question.api_id }
  node(:value){|r| r.value }
end
