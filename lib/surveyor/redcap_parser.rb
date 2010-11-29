require 'fastercsv'
require 'active_support' # for humanize
module Surveyor
  class RedcapParser
    # Attributes
    attr_accessor :context

    # Class methods
    def self.parse(str, filename)
      puts
      Surveyor::RedcapParser.new.parse(str, filename)
      puts
      puts
    end
    
    # Instance methods
    def initialize
      self.context = {}
    end
    def parse(str, filename)
      begin
        FasterCSV.parse(str, :headers => :first_row, :return_headers => true, :header_converters => :symbol) do |r|
          if r.header_row? # header row
            return puts "Missing headers: #{missing_columns(r).inspect}\n\n" unless missing_columns(r).blank?
            context[:survey] = Survey.new(:title => filename)
            print "survey_#{context[:survey].access_code} "
          else # non-header rows
            SurveySection.build_or_set(context, r)
            Question.build_and_set(context, r)
            Answer.build_and_set(context, r)
            Validation.build_and_set(context, r)
            # Dependency.build_and_set(context, r)
          end
        end
        print context[:survey].save ? "saved. " : " not saved! #{context[:survey].errors.each_full{|x| x }.join(", ")} "
        # print context[:survey].sections.map(&:questions).flatten.map(&:answers).flatten.map{|x| x.errors.each_full{|y| y}.join}.join
      rescue FasterCSV::MalformedCSVError
        puts = "Oops. Not a valid CSV file."
      # ensure
      end
    end
    def missing_columns(r)
      required_columns - r.headers.map(&:to_s)
    end
    def required_columns
      %w(variable__field_name form_name field_units section_header field_type field_label choices_or_calculations field_note text_validation_type text_validation_min text_validation_max identifier branching_logic_show_field_only_if required_field)
    end
  end
end

# Surveyor models with extra parsing methods
class Survey < ActiveRecord::Base
  include Surveyor::Models::SurveyMethods
end
class SurveySection < ActiveRecord::Base
  include Surveyor::Models::SurveySectionMethods
  def self.build_or_set(context, r)
    unless context[:survey_section] && context[:survey_section].reference_identifier == r[:form_name]
      if match = context[:survey].sections.detect{|ss| ss.reference_identifier == r[:form_name]}
        context[:current_survey_section] = match
      else
        context[:survey_section] = context[:survey].sections.build({:title => r[:form_name].to_s.humanize, :reference_identifier => r[:form_name]})
        print "survey_section_#{context[:survey_section].reference_identifier} "
      end
    end
  end
end
class QuestionGroup < ActiveRecord::Base
  include Surveyor::Models::QuestionGroupMethods
end
class Question < ActiveRecord::Base
  include Surveyor::Models::QuestionMethods
  def self.build_and_set(context, r)
    if !r[:section_header].blank?
      context[:survey_section].questions.build({:display_type => "label", :text => r[:section_header]})
      print "label_ "
    end
    context[:question] = context[:survey_section].questions.build({
      :reference_identifier => r[:variable__field_name],
      :text => r[:field_label],
      :help_text => r[:field_note],
      :is_mandatory => (/^y/i.match r[:required_field]) ? true : false,
      :pick => pick_from_field_type(r[:field_type]),
      :display_type => display_type_from_field_type(r[:field_type])
    })
    print "question_#{context[:question].reference_identifier} "
  end
  def self.pick_from_field_type(ft)
    {"checkbox" => :any, "radio" => :one}[ft] || :none
  end
  def self.display_type_from_field_type(ft)
    {"text" => :string, "dropdown" => :dropdown, "notes" => :text}[ft]
  end
end
class Dependency < ActiveRecord::Base
  include Surveyor::Models::DependencyMethods
  def self.decompose_rule(str)
    letters = ('A'..'Z').to_a
    rule = str
    components = str.split(/\band\b|\bor\b|\((?!\d)|\)(?!\(|\])/).reject(&:blank?).map(&:strip)
    components.each{|part| rule = rule.gsub(part){letters.shift} }
    {:rule => rule, :components => components}
  end
  # def self.build_and_set(context, r)
  #   unless (bl = r[:branching_logic]).blank?
  #     rule = bl
  #     @letters = ('A'..'Z').to_a
  #     condition_clauses = bl.split(/ and | or |\(|\)/).reject{|x| x.empty?}
  #     condition_clauses.each{|part| rule = rule.gsub(part){@letters.shift} }
  #     context[:dependency] = context[:question].build_dependency(:rule => rule)
  # 
  #     condition_clauses.each_with_index do |clause, i|
  #       if match = clause.match /\[([^\]]+)\] ?([^\ \"]+) ?"?([^"]+)"?/
  #         # e.g. [f1_q28] ="1"
  #         
  #         if match[0].match /(\w+)\(\d+\)/ 
  #         
  #         elsif match[0].match /(\w+)(\(\d+?\)+)/
  #         # [f1_q7(11)] = "1" or [initial_119(1)(2)(3)(4)(6)] = "1"
  #         
  #         
  #         # [initial_119(1)(2)(3)(4)(6)] = "1"
  #         
  #         
  #         
  #         context[:dependency_condition] = context[:dependency].dependency_conditions.build(:question_reference = match[1], :operator => match[2], :answer_reference => match[3], :lookup_reference => context[:lookup])
  #       elsif match = clause.match /"(\d+)"/
  #         # e.g. "2" from [initial_52] = "1" or "2" or "3"
  #         if context[:dependency_condition].nil? or i == 0
  #           # uh oh, we're first!
  #           puts "\n!!! skipping dependency condition #{clause}"
  #         else
  #           # borrow from our previous sibling
  #           context[:dependency_condition] = context[:dependency].dependency_conditions.build(:question_reference = context[:dependency_condition].question_reference, :operator => operator = context[:dependency_condition].operator, :answer_reference => answer_reference = match[1], :lookup_reference => context[:lookup])
  #         end
  #       end
  #       context[:dependency].dependency_conditions.build
  #     end
  #   end
  # end
end
class DependencyCondition < ActiveRecord::Base
  include Surveyor::Models::DependencyConditionMethods
  attr_accessor :question_reference, :answer_reference, :lookup_reference
  before_save :resolve_references
  def resolve_references
    
  end
end
class Answer < ActiveRecord::Base
  include Surveyor::Models::AnswerMethods
  def self.build_and_set(context, r)
    r[:choices_or_calculations].to_s.split("|").each do |pair|
      aref, atext = pair.strip.split(", ")
      if aref.blank? or atext.blank?
        puts "\n!!! skipping answer #{pair}"
      else
        context[:answer] = context[:question].answers.build(:reference_identifier => aref, :text => atext)
        unless context[:question].reference_identifier.blank or aref.blank or !context[:answer].valid?
          context[:lookup] << [context[:question].reference_identifier, aref, context[:answer]]
        end
        puts "#{context[:answer].errors.full_messages}, #{context[:answer].inspect}" unless context[:answer].valid?
        print "answer_#{context[:answer].reference_identifier} "
      end
    end
  end
end
class Validation < ActiveRecord::Base
  include Surveyor::Models::ValidationMethods
  def self.build_and_set(context, r)
    # text_validation_type text_validation_min text_validation_max
    min = r[:text_validation_min].to_s.blank? ? nil : r[:text_validation_min].to_s
    max = r[:text_validation_max].to_s.blank? ? nil : r[:text_validation_max].to_s
    type = r[:text_validation_type].to_s.blank? ? nil : r[:text_validation_type].to_s
    if min or max
      context[:question].answers.each do |a|
        context[:validation] = a.validations.build(:rule => min ? max ? "A and B" : "A" : "B")
        context[:validation].validation_conditions.build(:rule_key => "A", :operator => ">=", :integer_value => min) if min
        context[:validation].validation_conditions.build(:rule_key => "B", :operator => "<=", :integer_value => max) if max
      end
    elsif type
      # date email integer number phone
      case r[:text_validation_type]
      when "date"
        context[:question].display_type = :date if context[:question].display_type == :string
      when "email"
        context[:question].answers.each do |a|
          context[:validation] = a.validations.build(:rule => "A")
          context[:validation].validation_conditions.build(:rule_key => "A", :operator => "=~", :regexp_value => "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$")
        end
      when "integer"
        context[:question].display_type = :integer if context[:question].display_type == :string
        context[:question].answers.each do |a|
          context[:validation] = a.validations.build(:rule => "A")
          context[:validation].validation_conditions.build(:rule_key => "A", :operator => "=~", :regexp_value => "\d+")
        end
      when "number"
        context[:question].display_type = :float if context[:question].display_type == :string
        context[:question].answers.each do |a|
          context[:validation] = a.validations.build(:rule => "A")
          context[:validation].validation_conditions.build(:rule_key => "A", :operator => "=~", :regexp_value => "^\d*(,\d{3})*(\.\d*)?$")
        end
      when "phone"
        context[:question].answers.each do |a|
          context[:validation] = a.validations.build(:rule => "A")
          context[:validation].validation_conditions.build(:rule_key => "A", :operator => "=~", :regexp_value => "\d{3}.*\d{4}")
        end
      end
    end
  end
  
end
class ValidationCondition < ActiveRecord::Base
  include Surveyor::Models::ValidationConditionMethods
end
