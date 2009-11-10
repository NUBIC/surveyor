module SurveyParser
  class SurveySection < SurveyParser::Base
    # Context, Content, Display, Reference, Children, Placeholders
    attr_accessor :id, :parser, :survey_id
    attr_accessor :title, :description
    attr_accessor :reference_identifier, :data_export_identifier, :common_namespace, :common_identitier
    attr_accessor :display_order, :custom_class
    has_children :question_groups, :questions

    def parse_args(args)
      title = args[0]
      {:title => title, :data_export_identifier => Surveyor.to_normalized_string(title)}.merge(args[1] || {})
    end

    # Used to find questions for dependency linking
    def find_question_by_reference(ref_id)
      self.questions.detect{|q| q.reference_identifier == ref_id}
    end
  
  end
end