class SurveyorRadioInput < Formtastic::Inputs::RadioInput
  include Surveyor::Helpers::FormtasticCustomInput
  def to_html
    super
  end
  def choice_html(choice)
    output = "" 
    output << template.content_tag(:label,
      builder.radio_button(input_name, choice_value(choice), input_html_options.merge(choice_html_options(choice)).merge(:required => false)) << 
      choice_label(choice),
      label_html_options.merge(:for => choice_input_dom_id(choice), :class => nil)
    )
    output << builder.text_field(:response_other, input_html_options_with(choice, :response_other)) if options[:response_class] == "other_and_string"
    output << builder.text_field(response_class_to_method(options[:response_class]), input_html_options_with(choice, options[:response_class])) if %w(date datetime time float integer string other_and_string).include? options[:response_class]
    output << builder.text_area(:text_value, input_html_options_with(choice, :text_value)) if options[:response_class] == "text"
    output.html_safe
  end
end