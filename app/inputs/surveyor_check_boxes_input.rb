class SurveyorCheckBoxesInput < Formtastic::Inputs::CheckBoxesInput
  include Surveyor::Helpers::FormtasticCustomInput
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
    output << builder.text_field(response_class_to_method(options[:response_class]), input_html_options_with(choice, options[:response_class])) if %w(date datetime time float integer string other_and_string).include? options[:response_class]
    output << builder.text_area(:text_value, input_html_options_with(choice, :text_value)) if options[:response_class] == "text"
    output.html_safe
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
