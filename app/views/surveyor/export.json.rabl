Rabl.configure {|config| config.include_json_root = false }

object @survey
attributes :title, :api_id => :uuid
node(:description,            :if => lambda {|s| !s.description.blank? }){|s| s.description }
node(:reference_identifier,   :if => lambda {|s| !s.reference_identifier.blank? }){|s| s.reference_identifier }

child :sections => :sections do
  attributes :title, :display_order
  node(:description,            :if => lambda {|s| !s.description.blank? }){|s| s.description }
  node(:reference_identifier,   :if => lambda {|s| !s.reference_identifier.blank? }){|s| s.reference_identifier }
  
  child :questions_and_groups => :questions_and_groups do
    # both questions and question_groups have uuid, text, help_text, reference_identifier, and type
    attributes :api_id => :uuid
    node(:text,                 :if => lambda { |q| q.is_a?(Question)}){ |q| q.split_text(:pre) }
    node(:text,                 :if => lambda { |q| q.is_a?(QuestionGroup)}){ |q| q.text }
    node(:help_text,            :if => lambda { |q| !q.help_text.blank? }){ |q| q.help_text }
    node(:reference_identifier, :if => lambda { |q| !q.reference_identifier.blank? }){ |q| q.reference_identifier }
    node(:type,                 :if => lambda { |q| q.display_type != "default" }){ |q| q.display_type }
    
    # only questions
    node(:pick,                 :if => lambda { |q| q.is_a?(Question) && q.pick != "none" }){ |q| q.pick }
    node(:post_text,            :if => lambda { |q| q.is_a?(Question) && !q.split_text(:post).blank? }){ |q| q.split_text(:post) }
  
    child :answers, :if => lambda { |q| q.is_a?(Question) && !q.answers.blank? } do
      attributes :api_id => :uuid
      node(:help_text, :if => lambda { |a| !a.help_text.blank? }){ |a| a.help_text }
      node(:is_exclusive, :if => lambda { |a| a.is_exclusive }){ |a| a.is_exclusive }
      node(:text){ |a| a.split_or_hidden_text(:pre) }
      node(:post_text, :if => lambda { |a| !a.split_or_hidden_text(:post).blank? }){ |a| a.split_or_hidden_text(:post) }
      node(:type, :if => lambda { |a| a.response_class != "answer" }){ |a| a.response_class }
    end
    
    # both questions and question_groups have dependencies
    child :dependency, :if => lambda { |q| q.dependency } do
      attributes :rule
      child :dependency_conditions => :conditions do
        attributes :rule_key, :operator
        node(:question){ |d| d.question.api_id }
        node(:answer, :if => lambda { |d| d.answer }){ |d| d.answer.api_id }
        node(:value, :if => lambda { |d| d.answer && d.answer.response_class != "answer" && d.as(d.answer.response_class) }){ |d| d.as(d.answer.response_class)}
      end
    end
    
    child(:questions, :if => lambda{|x| x.is_a?(QuestionGroup)}) do
      attributes :api_id => :uuid
      node(:text){ |q| q.split_text(:pre) }
      node(:post_text, :if => lambda { |q| !q.split_text(:post).blank? }){ |q| q.split_text(:post) }
      node(:help_text, :if => lambda { |q| !q.help_text.blank? }){ |q| q.help_text }
      node(:reference_identifier, :if => lambda { |q| !q.reference_identifier.blank? }){ |q| q.reference_identifier }
      node(:type, :if => lambda { |q| q.display_type != "default" }){ |q| q.display_type }
      node(:pick, :if => lambda { |q| q.pick != "none" }){ |q| q.pick }
  
      child :answers, :if => lambda { |q| !q.answers.blank? } do
        attributes :api_id => :uuid
        node(:help_text, :if => lambda { |a| !a.help_text.blank? }){ |a| a.help_text }
        node(:is_exclusive, :if => lambda { |a| a.is_exclusive }){ |a| a.is_exclusive }
        node(:text){ |a| a.split_or_hidden_text(:pre) }
        node(:post_text, :if => lambda { |a| !a.split_or_hidden_text(:post).blank? }){ |a| a.split_or_hidden_text(:post) }
        node(:type, :if => lambda { |a| a.response_class != "answer" }){ |a| a.response_class }
      end
  
      child :dependency, :if => lambda { |q| q.dependency } do
        attributes :rule
        child :dependency_conditions => :conditions do
          attributes :rule_key, :operator
          node(:question){ |d| d.question.api_id }
          node(:answer, :if => lambda { |d| d.answer }){ |d| d.answer.api_id }
          node(:value, :if => lambda { |d| d.answer && d.answer.response_class != "answer" && d.as(d.answer.response_class) }){ |d| d.as(d.answer.response_class)}
        end
      end
    end
  end

end