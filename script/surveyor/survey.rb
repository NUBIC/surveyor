module SurveyParser
  class Survey < SurveyParser::Base
    # Context, Content, Reference, Expiry, Display
    attr_accessor :id, :parser
    attr_accessor :title, :description
    attr_accessor :access_code, :reference_identifier, :data_export_identifier, :common_namespace, :common_identitier
    attr_accessor :active_at, :inactive_at
    attr_accessor :css_url, :custom_class
    has_children :survey_sections
  
    def parse_args(args)
      title = args[0]
      {:title => title, :access_code => Surveyor.to_normalized_string(title)}.merge(args[1] || {})
    end

    def find_question_by_reference(ref_id)
      found = nil
      survey_sections.detect{|s| found = s.find_question_by_reference(ref_id)}
      return found
    end
  
    def reconcile_dependencies
      survey_sections.each do |section|
        section.questions.each do |question| 
          question.dependency.dependency_conditions.each { |con| con.reconcile_dependencies} unless question.dependency.nil?
        end
        section.question_groups.each do |group|
          group.dependency.dependency_conditions.each { |con| con.reconcile_dependencies} unless group.dependency.nil?
        end
      end  
    end

  end
end