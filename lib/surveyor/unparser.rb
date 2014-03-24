%w(survey survey_section question_group question dependency dependency_condition answer validation validation_condition).each {|model| require model }
module Surveyor
  class Unparser
    # Class methods
    def self.unparse(survey)
      survey.unparse(dsl = "")
      dsl
    end

    # cribbed from rails source: http://apidock.com/rails/v3.2.13/Hash/diff
    def self.hash_diff(h1, h2)
      h1.dup.delete_if { |k, v| h2[k] == v }.merge!(h2.dup.delete_if { |k, v| h1.has_key?(k) })
    end
  end
end

# Surveyor models with extra parsing methods
class Survey < ActiveRecord::Base
  # block

  def unparse(dsl)
    with_defaults = Survey.new(:title => title)
    attrs = self.attributes.delete_if{|k,v| with_defaults[k] == v or %w(created_at updated_at inactive_at id title access_code api_id).include? k}.symbolize_keys!
    dsl << "survey \"#{title}\""
    dsl << (attrs.blank? ? " do\n" : ", #{attrs.inspect.gsub(/\{|\}/, "")} do\n")
    sections.each{|section| section.unparse(dsl)}
    dsl << "end\n"
  end
end
class SurveySection < ActiveRecord::Base
  # block

  def unparse(dsl)
    with_defaults = SurveySection.new(:title => title)
    attrs = self.attributes.delete_if{|k,v| with_defaults[k] == v or %w(created_at updated_at id survey_id).include? k}.symbolize_keys!
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

  def unparse(dsl)
    with_defaults = QuestionGroup.new(:text => text)
    attrs = self.attributes.delete_if{|k,v| with_defaults[k] == v or %w(created_at updated_at id api_id).include?(k) or (k == "display_type" && %w(grid repeater default).include?(v))}.symbolize_keys!
    method = (%w(grid repeater).include?(display_type) ? display_type : "group")
    dsl << "\n"
    dsl << "    #{method} \"#{text}\""
    dsl << (attrs.blank? ? " do\n" : ", #{attrs.inspect.gsub(/\{|\}/, "")} do\n")
    questions.first.answers.each{|answer| answer.unparse(dsl)} if display_type == "grid"
    questions.each{|question| question.unparse(dsl)}
    dsl << "    end\n"
  end
end
class Question < ActiveRecord::Base
  # nonblock

  def unparse(dsl)
    with_defaults = Question.new(:text => text)
    attrs = self.attributes.delete_if{|k,v| with_defaults[k] == v or %w(created_at updated_at reference_identifier id survey_section_id question_group_id api_id).include?(k) or (k == "display_type" && v == "label")}.symbolize_keys!
    dsl << (solo? ? "\n" : "  ")
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

  def unparse(dsl)
    with_defaults = Dependency.new
    attrs = self.attributes.delete_if{|k,v| with_defaults[k] == v or %w(created_at updated_at id question_id).include?(k) }.symbolize_keys!
    dsl << "  " if question.part_of_group?
    dsl << "    dependency"
    dsl << (attrs.blank? ? "\n" : " #{attrs.inspect.gsub(/\{|\}/, "")}\n")
    dependency_conditions.each{|dependency_condition| dependency_condition.unparse(dsl)}
  end
end
class DependencyCondition < ActiveRecord::Base
  # nonblock

  def unparse(dsl)
    with_defaults = DependencyCondition.new
    attrs = self.attributes.delete_if{|k,v| with_defaults[k] == v or %w(created_at updated_at question_id question_group_id rule_key rule operator id dependency_id answer_id).include? k}.symbolize_keys!
    dsl << "  " if dependency.question.part_of_group?
    dsl << "    condition"
    dsl << "_#{rule_key}" unless rule_key.blank?
    dsl << " :q_#{question.reference_identifier}, \"#{operator}\""
    dsl << (attrs.blank? ? ", {:answer_reference=>\"#{answer && answer.reference_identifier}\"}\n" : ", {#{attrs.inspect.gsub(/\{|\}/, "")}, :answer_reference=>\"#{answer && answer.reference_identifier}\"}\n")
  end  
end
class Answer < ActiveRecord::Base
  # nonblock

  def unparse(dsl)
    with_defaults = Answer.new(:text => text)
    attrs = self.attributes.delete_if{|k,v| with_defaults[k] == v or %w(created_at updated_at reference_identifier response_class id question_id api_id).include? k}.symbolize_keys!
    attrs.delete(:is_exclusive) if text == "Omit" && is_exclusive == true
    attrs.merge!({:is_exclusive => false}) if text == "Omit" && is_exclusive == false
    dsl << "  " if question.part_of_group?
    dsl << "    a"
    dsl << "_#{reference_identifier}" unless reference_identifier.blank?
    if response_class.to_s.titlecase == text && attrs == {:display_type => "hidden_label"}
      dsl << " :#{response_class}"
    else    
      dsl << [ text.blank? ? nil : text == "Other" ? " :other" : text == "Omit" ? " :omit" : " \"#{text}\"",
                (response_class.blank? or response_class == "answer") ? nil : " #{response_class.to_sym.inspect}",
                attrs.blank? ? nil : " #{attrs.inspect.gsub(/\{|\}/, "")}\n"].compact.join(",")
    end
    dsl << "\n"
    validations.each{|validation| validation.unparse(dsl)}
  end
end
class Validation < ActiveRecord::Base
  # nonblock

  def unparse(dsl)
    with_defaults = Validation.new
    attrs = self.attributes.delete_if{|k,v| with_defaults[k] == v or %w(created_at updated_at id answer_id).include?(k) }.symbolize_keys!
    dsl << "  " if answer.question.part_of_group?
    dsl << "    validation"
    dsl << (attrs.blank? ? "\n" : " #{attrs.inspect.gsub(/\{|\}/, "")}\n")
    validation_conditions.each{|validation_condition| validation_condition.unparse(dsl)}
  end
end
class ValidationCondition < ActiveRecord::Base
  # nonblock

  def unparse(dsl)
    with_defaults = ValidationCondition.new
    attrs = self.attributes.delete_if{|k,v| with_defaults[k] == v or %w(created_at updated_at operator rule_key id validation_id).include? k}.symbolize_keys!
    dsl << "  " if validation.answer.question.part_of_group?
    dsl << "    condition"
    dsl << "_#{rule_key}" unless rule_key.blank?
    dsl << " \"#{operator}\""
    dsl << (attrs.blank? ? "\n" : ", #{attrs.inspect.gsub(/\{|\}/, "")}\n")
  end
end
