object @response_set
attribute :api_id => :uuid
attribute :created_at
node(:created_at){|rs| rs.created_at.utc }
node(:completed_at){|rs| rs.completed_at.try(:utc) }
node(:survey_id){|rs| rs.survey.api_id }

child :responses do
  attribute :api_id => :uuid
  node(:created_at){|r| r.created_at.utc }
  node(:modified_at){|r| r.updated_at.utc }
  node(:answer_id){|r| r.answer.api_id }
  node(:question_id){|r| r.question.api_id }
  node(:value, :if => lambda{|r| r.answer.response_class != "answer"}){|r| r.as(r.answer.response_class) }
end
