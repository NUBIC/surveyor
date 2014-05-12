module Surveyor
  module Helpers
    module FormtasticCustomInput
      def input_html_options_with(choice, response_class)
        input_html_options.merge(choice_html_options(choice)).merge({:id => (input_html_options[:id] || "answer_id").gsub("answer_id", response_class_to_method(response_class).to_s), :class => [input_html_options[:class], response_class].join(" ")})
      end
      def response_class_to_method(type_sym)
        # doesn't handle response_class == answer, and doesn't have to
        "#{type_sym.to_s}_value".to_sym
      end
    end
  end
end