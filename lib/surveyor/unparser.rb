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
    group_questions = []
    dsl << "  section \"#{title}\""
    dsl << (attrs.blank? ? " do\n" : ", #{attrs.inspect.gsub(/\{|\}/, "")} do\n")
    questions.each_with_index do |question, index|
      if question.solo?
        question.unparse(dsl)
      else # gather up the group questions
        group_questions << question
        if (index + 1 >= questions.size) or (question.question_group != questions[index + 1].question_group)
          # this is the last question of the section, or the group
          question.question_group.unparse(dsl)
        end
        group_questions = []
      end
    end
    dsl << "  end\n"
  end
end
class QuestionGroup < ActiveRecord::Base
  # block
  include Surveyor::Models::QuestionGroupMethods
  def unparse(dsl)
    attrs = (self.attributes.diff QuestionGroup.new(:text => text).attributes).delete_if{|k,v| k == "display_type" && %w(grid repeater default).include?(v) }.symbolize_keys!
    method = (%w(grid repeater).include?(display_type) ? display_type : "group")
    dsl << "    #{method} \"#{text}\""
    dsl << (attrs.blank? ? " do\n" : ", #{attrs.inspect.gsub(/\{|\}/, "")} do\n")
    questions.first.answers.each{|answer| answer.unparse(dsl)} if display_type == "grid"
    questions.each{|question| question.unparse(dsl)}
    dsl << "    end\n"
  end
end
class Question < ActiveRecord::Base
  # nonblock
  include Surveyor::Models::QuestionMethods
  def unparse(dsl)
    attrs = (self.attributes.diff Question.new(:text => text).attributes).delete_if{|k,v| k == "reference_identifier" or (k == "display_type" and v == "label")}.symbolize_keys!
    dsl << "\n"
    dsl << "  " if part_of_group?
    if display_type == "label"
      dsl << "    label"
    else
      dsl << "    q"
    end
    dsl << "_#{reference_identifier}" unless reference_identifier.blank?
    dsl << " \"#{text}\""
    dsl << (attrs.blank? ? "\n" : ", #{attrs.inspect.gsub(/\{|\}/, "")}\n")
    if solo? or question_group.display_type != "grid"
      answers.each{|answer| answer.unparse(dsl)}
    end
    dependency.unparse(dsl) if dependency
  end
end
class Dependency < ActiveRecord::Base
  # nonblock
  include Surveyor::Models::DependencyMethods
  def unparse(dsl)
    attrs = (self.attributes.diff Dependency.new.attributes).delete_if{|k,v| false }.symbolize_keys!
    dsl << "  " if question.part_of_group?
    dsl << "    dependency"
    dsl << (attrs.blank? ? "\n" : " #{attrs.inspect.gsub(/\{|\}/, "")}\n")
    dependency_conditions.each{|dependency_condition| dependency_condition.unparse(dsl)}
  end
end
class DependencyCondition < ActiveRecord::Base
  # nonblock
  include Surveyor::Models::DependencyConditionMethods  
  def unparse(dsl)
    attrs = (self.attributes.diff Dependency.new.attributes).delete_if{|k,v| %w(question_id rule_key rule operator question_group_id).include? k}.symbolize_keys!
    dsl << "  " if dependency.question.part_of_group?
    dsl << "    condition"
    dsl << "_#{rule_key}" unless rule_key.blank?
    dsl << " :q_#{question.reference_identifier}, \"#{operator}\""
    dsl << (attrs.blank? ? "\n" : ", {#{attrs.inspect.gsub(/\{|\}/, "")}, :answer_reference=>\"#{answer.reference_identifier}\"}\n")
  end  
end
class Answer < ActiveRecord::Base
  # nonblock
  include Surveyor::Models::AnswerMethods
  def unparse(dsl)
    attrs = (self.attributes.diff Answer.new(:text => text).attributes).delete_if{|k,v| %w(reference_identifier response_class).include? k}.symbolize_keys!
    dsl << "  " if question.part_of_group?
    dsl << "    a"
    dsl << "_#{reference_identifier}" unless reference_identifier.blank?
    
    dsl << [ text.blank? ? nil : text == "Other" ? " :other" : text == "Omit" ? " :omit" : " \"#{text}\"",
              (response_class.blank? or response_class == "answer") ? nil : " #{response_class.to_sym.inspect}",
              attrs.blank? ? nil : " #{attrs.inspect.gsub(/\{|\}/, "")}\n"].compact.join(",")
    dsl << "\n"
    validations.each{|validation| validation.unparse(dsl)}
  end
end
class Validation < ActiveRecord::Base
  # nonblock
  include Surveyor::Models::ValidationMethods
  def unparse(dsl)
    attrs = (self.attributes.diff Validation.new.attributes).delete_if{|k,v| false }.symbolize_keys!
    dsl << "  " if answer.question.part_of_group?
    dsl << "    validation"
    dsl << (attrs.blank? ? "\n" : " #{attrs.inspect.gsub(/\{|\}/, "")}\n")
    validation_conditions.each{|validation_condition| validation_condition.unparse(dsl)}
  end
end
class ValidationCondition < ActiveRecord::Base
  # nonblock
  include Surveyor::Models::ValidationConditionMethods
  def unparse(dsl)
    attrs = (self.attributes.diff ValidationCondition.new.attributes).delete_if{|k,v| %w(operator rule_key).include? k}.symbolize_keys!
    dsl << "  " if validation.answer.question.part_of_group?
    dsl << "    condition"
    dsl << "_#{rule_key}" unless rule_key.blank?
    dsl << " \"#{operator}\""
    dsl << (attrs.blank? ? "\n" : ", #{attrs.inspect.gsub(/\{|\}/, "")}\n")
  end
end
