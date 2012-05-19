class SurveyorCheckBoxesInput < Formtastic::Inputs::CheckBoxesInput
  def to_html
    super
  end
  def choice_html(choice)
    output = "" 
    output << template.content_tag(:label,
      hidden_fields? ?
        check_box_with_hidden_input(choice) :
        check_box_without_hidden_input(choice) <<
      choice_label(choice),
      label_html_options.merge(:for => choice_input_dom_id(choice), :class => nil)
    )
    output << builder.text_field(:response_other, input_html_options_with(choice, :response_other)) if options[:response_class] == "other_and_string"
    output << builder.text_field(:string_value, input_html_options_with(choice, :string_value)) if options[:response_class] == "other_and_string" or options[:response_class] == "string" or options[:response_class] == "integer" or options[:response_class] == "float"
    output << builder.text_area(:text_value, input_html_options_with(choice, :text_value)) if options[:response_class] == "text"
    output.html_safe
  end
  def input_html_options_with(choice, sym)
    input_html_options.merge(choice_html_options(choice)).merge({:id => (input_html_options[:id] || "answer_id").gsub("answer_id", sym.to_s)})
  end
  def checked?(value)
    selected_values.include?(value.to_s)
  end
  def disabled?(value)
    disabled_values.include?(value) || input_html_options[:disabled] == true
  end
  def make_selected_values
    if object.respond_to?(method)
      selected_items = [object.send(method)].compact.flatten.map(&:to_s)
      
      [*selected_items.map { |o| send_or_call_or_object(value_method, o) }].compact
    else
      []
    end
  end
end
