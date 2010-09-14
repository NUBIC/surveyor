module Surveyor
  class Unparser
    # Class methods
    def self.unparse(survey)
      survey.unparse(dsl = "")
      dsl
    end
  end
end

# Surveyor models with extra parsing methods
class Survey < ActiveRecord::Base
  # block
  include Surveyor::Models::SurveyMethods
  def unparse(dsl)
    attrs = (self.attributes.diff Survey.new(:title => title).attributes).delete_if{|k,v| k == "inactive_at"}.symbolize_keys!
    dsl << "survey \"#{title}\""
    dsl << (attrs.blank? ? " do\n" : ", #{attrs.inspect.gsub(/\{|\}/, "")} do\n")
    sections.each{|section| section.unparse(dsl)}
    dsl << "end\n"
  end
end
class SurveySection < ActiveRecord::Base
  # block
  include Surveyor::Models::SurveySectionMethods
  def unparse(dsl)
    attrs = (self.attributes.diff SurveySection.new(:title => title).attributes).delete_if{|k,v| k == "inactive_at"}.symbolize_keys!
    dsl << "  section \"#{title}\""
    dsl << (attrs.blank? ? " do\n" : ", #{attrs.inspect.gsub(/\{|\}/, "")} do\n")
    questions.each{|question| question.unparse(dsl)}
    dsl << "  end\n"
  end
end
class QuestionGroup < ActiveRecord::Base
  # block
  include Surveyor::Models::QuestionGroupMethods
  
end
class Question < ActiveRecord::Base
  # nonblock
  include Surveyor::Models::QuestionMethods
  def unparse(dsl)
    attrs = (self.attributes.diff Question.new(:text => text).attributes).delete_if{|k,v| k == "reference_identifier"}.symbolize_keys!
    dsl << "    question"
    dsl << "_#{reference_identifier}" unless reference_identifier.blank?
    dsl << " \"#{text}\""
    dsl << (attrs.blank? ? "\n" : ", #{attrs.inspect.gsub(/\{|\}/, "")}\n")
  end
end
class Dependency < ActiveRecord::Base
  # nonblock
  include Surveyor::Models::DependencyMethods

end
class DependencyCondition < ActiveRecord::Base
  # nonblock
  include Surveyor::Models::DependencyConditionMethods

end
class Answer < ActiveRecord::Base
  # nonblock
  include Surveyor::Models::AnswerMethods

end
class Validation < ActiveRecord::Base

end
class ValidationCondition < ActiveRecord::Base
  # nonblock
  include Surveyor::Models::ValidationConditionMethods
end
