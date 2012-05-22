module Surveyor
  module Helpers
    module FormtasticCustomInput
      def input_html_options_with(choice, response_class)
        input_html_options.merge(choice_html_options(choice)).merge({:id => (input_html_options[:id] || "answer_id").gsub("answer_id", response_class_to_method(response_class).to_s), :class => [input_html_options[:class], response_class].join(" ")})
      end
      def response_class_to_method(response_class)
        # doesn't handle response_class == answer, and doesn't have to
        case response_class.to_s
        when /^other_and_string$/ then :string_value
        when /^date|time$/ then :datetime_value
        else "#{response_class}_value".to_sym
        end
      end      
    end
  end
end
