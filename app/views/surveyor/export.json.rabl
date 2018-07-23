object @survey
attribute :title
attribute :api_id                       => :uuid
node(:description,                  :if => lambda {|s| !s.description.blank? }){|s| s.description }
node(:reference_identifier,         :if => lambda {|s| !s.reference_identifier.blank? }){|s| s.reference_identifier }

child :sections => :sections do
  attributes :title, :display_order
  node(:description,                :if => lambda {|s| !s.description.blank? }){|s| s.description }
  node(:reference_identifier,       :if => lambda {|s| !s.reference_identifier.blank? }){|s| s.reference_identifier }

  child :questions_and_groups => :questions_and_groups do
    # both questions and question_groups have uuid, text, help_text, reference_identifier, and type
    attribute :api_id                   => :uuid
    attribute :is_mandatory
    node(:text,                     :if => lambda { |q| q.is_a?(Question)}){ |q| q.split(q.text, :pre) }
    node(:text,                     :if => lambda { |q| q.is_a?(QuestionGroup)}){ |q| q.text }
    node(:help_text,                :if => lambda { |q| !q.help_text.blank? }){ |q| q.help_text }
    node(:reference_identifier,     :if => lambda { |q| !q.reference_identifier.blank? }){ |q| q.reference_identifier }
    node(:data_export_identifier,   :if => lambda { |q| !q.data_export_identifier.blank? }){ |q| q.data_export_identifier }
    node(:type,                     :if => lambda { |q| q.display_type != "default" }){ |q| q.display_type }
    #needed for the mobile app to parse the question based on its answer response_class
    #Currently we are not supporting multiple answers when it's not a pick question that's why we are grabbing the first answer type
    node(:answer_type, :if => lambda { |q| q.is_a?(Question) && q.pick == "none" && q.answers.present? && q.display_type != "email"}){ |q| q.answers.first.response_class }
    node(:answer_type, :if => lambda {|q| q.is_a?(Question) && q.display_type == "email"}) {"email"}

    # only questions
    node(:pick,                     :if => lambda { |q| q.is_a?(Question) && q.pick != "none" }){ |q| q.pick }
    node(:post_text,                :if => lambda { |q| q.is_a?(Question) && !q.split(q.text, :post).blank? }){ |q| q.split(q.text, :post) }

    child :answers, :if => lambda { |q| q.is_a?(Question) && !q.answers.blank? } do
      attribute :api_id                 => :uuid
      node(:help_text,              :if => lambda { |a| !a.help_text.blank? }){ |a| a.help_text }
      node(:exclusive,              :if => lambda { |a| a.is_exclusive }){ |a| a.is_exclusive }
      node(:text, :if => lambda { |a| a.display_type != "image" }){ |a| a.split(a.text, :pre) }
      node(:url,  :if => lambda { |a| a.display_type == "image" }){ |a| a.split(a.text, :pre) }

      node(:post_text,              :if => lambda { |a| !a.split(a.text, :post).blank? }){ |a| a.split(a.text, :post) }
      node(:type,                   :if => lambda { |a| a.response_class != "answer" }){ |a| a.response_class }
      node(:reference_identifier,   :if => lambda { |a| !a.reference_identifier.blank? }){ |a| a.reference_identifier }
      node(:data_export_identifier, :if => lambda { |a| !a.data_export_identifier.blank? }){ |a| a.data_export_identifier }
      node(:input_mask, :if => lambda { |a| !a.input_mask.blank? }){ |a| a.input_mask }
      node(:input_mask_placeholder, :if => lambda { |a| !a.input_mask_placeholder.blank? }){ |a| a.input_mask_placeholder }
      node(:display_type, :if => lambda { |a| a.display_type.present? && a.display_type != "default" }){ |a| a.display_type }
      node(:short_text, :if => lambda { |a| a.short_text.present? }){ |a| a.split( a.short_text, :pre) }

      child :validations, if: lambda { |q| q.validations.present? } do
        attributes :rule
        node( :message, if: lambda{ |q| q.message.present? } ) { |q| q.message }
        child :validation_conditions, if: lambda{ |q| q.validation_conditions.present? } do
          attributes :rule_key, :operator
          node( :values ) { |d| d.datetime_value || d.integer_value || d.float_value || d.text_value || d.string_value }
          node( :unit, if: lambda{ |d| d.unit.present? }) { |d| d.unit }
        end
      end
    end

    # both questions and question_groups have dependencies
    child :dependency, :if => lambda { |q| q.dependency } do
      attributes :rule
      child :dependency_conditions => :conditions do
        attributes :rule_key, :operator
        node(:question){ |d| d.question.api_id }
        node(:answer, :if => lambda { |d| d.answer }){ |d| d.answer.api_id }
        node(:value, :if => lambda { |d| d.answer && d.answer.response_class != "answer" && d.as(d.answer.response_class) }){ |d| d.as(d.answer.response_class)}
        node( :condition_value ) { |d| d.datetime_value || d.integer_value || d.float_value || d.text_value || d.string_value }
      end
    end

    child(:questions, :if => lambda{|x| x.is_a?(QuestionGroup)}) do
      attributes :api_id => :uuid
      node(:text){ |q| q.split(q.text, :pre) }
      node(:post_text, :if => lambda { |q| !q.split(q.text, :post).blank? }){ |q| q.split(q.text, :post) }
      node(:help_text, :if => lambda { |q| !q.help_text.blank? }){ |q| q.help_text }
      node(:reference_identifier, :if => lambda { |q| !q.reference_identifier.blank? }){ |q| q.reference_identifier }
      node(:data_export_identifier,   :if => lambda { |q| !q.data_export_identifier.blank? }){ |q| q.data_export_identifier }
      #needed for the mobile app to parse the question based on its answer response_class
      #Currently we are not supporting multiple answers when it's not a pick question that's why we are grabbing the first answer type
      node(:answer_type, :if => lambda { |q| q.pick == "none" && q.answers.present? }){ |q| q.answers.first.response_class }
      node(:pick, :if => lambda { |q| q.pick != "none" }){ |q| q.pick }

      child :answers, :if => lambda { |q| !q.answers.blank? } do
        attributes :api_id => :uuid
        node(:help_text, :if => lambda { |a| !a.help_text.blank? }){ |a| a.help_text }
        node(:is_exclusive, :if => lambda { |a| a.is_exclusive }){ |a| a.is_exclusive }
        node(:text){ |a| a.split(a.text, :pre) }
        node(:post_text, :if => lambda { |a| !a.split(a.text, :post).blank? }){ |a| a.split(a.text, :post) }
        node(:type, :if => lambda { |a| a.response_class != "answer" }){ |a| a.response_class }
        node(:reference_identifier,   :if => lambda { |a| !a.reference_identifier.blank? }){ |a| a.reference_identifier }
        node(:data_export_identifier, :if => lambda { |a| !a.data_export_identifier.blank? }){ |a| a.data_export_identifier }
        node(:input_mask, :if => lambda { |a| !a.input_mask.blank? }){ |a| a.input_mask }
        node(:input_mask_placeholder, :if => lambda { |a| !a.input_mask_placeholder.blank? }){ |a| a.input_mask_placeholder }

        child :validations, if: lambda { |q| q.validations.present? } do
          attributes :rule
          node( :message, if: lambda{ |q| q.message.present? } ) { |q| q.message }
          child :validation_conditions, if: lambda{ |q| q.validation_conditions.present? } do
            attributes :rule_key, :operator
            node( :values ) { |d| d.datetime_value || d.integer_value || d.float_value || d.text_value || d.string_value }
            node( :unit, if: lambda{ |d| d.unit.present? }) { |d| d.unit }
          end
        end
      end

      child :dependency, :if => lambda { |q| q.dependency } do
        attributes :rule
        child :dependency_conditions => :conditions do
          attributes :rule_key, :operator
          node(:question){ |d| d.question.api_id }
          node(:answer, :if => lambda { |d| d.answer }){ |d| d.answer.api_id }
          node( :condition_value ) { |d| d.datetime_value || d.integer_value || d.float_value || d.text_value || d.string_value }
          node(:value, :if => lambda { |d| d.answer && d.answer.response_class != "answer" && d.as(d.answer.response_class) }){ |d| d.as(d.answer.response_class)}
        end
      end
    end
  end

end
