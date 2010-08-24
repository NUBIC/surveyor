module SurveyParser
  class Question < SurveyParser::Base
    ANSWER_ID = /\s*\w+_/ unless defined?(ANSWER_ID)
    
    # Context, Content, Reference, Display, Children
    attr_accessor :id, :parser, :survey_section_id, :question_group_id, :correct_answer_id
    attr_accessor :text, :short_text, :help_text, :pick, :answer_id
    attr_accessor :reference_identifier, :data_export_identifier, :common_namespace, :common_identifier
    attr_accessor :display_order, :display_type, :is_mandatory, :display_width, :custom_class, :custom_renderer
    attr_accessor :dependency
    has_children :answers
    
    def default_options
      { :pick => :none,
        :display_type => :default,
        :is_mandatory => true,
        :display_order => self.id
      }
    end
    
    def parse_opts(opts)
      (name = opts.delete(:method_name)) =~ /label|image/ ? opts.merge(:display_type => name) : opts
    end
    
    def parse_args(args)
      text = args[0] || "Question"
      {:text => text, :short_text => text, :data_export_identifier => Surveyor::Common.to_normalized_string(text)}.merge(args[1] || {})
    end
    
    def correct_answer=(a)
      self.answer_id = a.id
    end
  
    def find_answer_by_reference(ref_id)
      self.answers.detect{|a| a.reference_identifier == ref_id}
    end
    
    # currently, only one correct answer is allowed
    def find_current_answers(args)
      ref_ids = args[0][:answer]
      ids = ref_ids.to_s.split(ANSWER_ID).compact
      self.answers.select{|a| ids.include?(a.reference_identifier)}.first
    end
    
    # so we can build the correct yaml structure
    def property_name_map(property)
      names = {
        "answer" => "correct_answer"
      }
      return names.has_key?(property) ? names[property] : property
    end

    def to_file
      super
      if self.dependency then self.dependency.to_file end
    end

  end
end