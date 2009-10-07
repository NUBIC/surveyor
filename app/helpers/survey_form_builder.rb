class SurveyFormBuilder < ActionView::Helpers::FormBuilder 
  def survey_check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
    fields = @template.survey_check_box(@object_name, method, options.merge(:object => @object), checked_value, unchecked_value)
    fields[1]
  end
end

module ActionView
  module Helpers
    module FormHelper
      def survey_check_box(object_name, method, options = {}, checked_value = "1", unchecked_value = "0")
        if (Rails::VERSION::STRING.to_f > 2.1)
          InstanceTag.new(object_name, method, self, options.delete(:object)).to_survey_check_box_tag(options, checked_value, unchecked_value)
        else
          InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_survey_check_box_tag(options, checked_value, unchecked_value)
        end
      end
    end

    class InstanceTag
      def to_survey_check_box_tag(options = {}, checked_value = "1", unchecked_value = "0")
        options = options.stringify_keys
        options["type"]     = "checkbox"
        options["value"]    = checked_value
        if options.has_key?("checked")
          cv = options.delete "checked"
          checked = cv == true || cv == "checked"
        else
          checked = self.class.check_box_checked?(value(object), checked_value)
        end
        options["checked"] = "checked" if checked
        add_default_name_and_id(options)
        [tag("input", "name" => options["name"], "type" => "hidden", "value" => unchecked_value), tag("input", options)]
      end
    end
  end
end