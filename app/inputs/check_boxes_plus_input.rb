class CheckBoxesPlusInput < SimpleForm::Inputs::CollectionCheckBoxesInput
  def input(wrapper_options = nil)
    label_method, value_method = detect_collection_methods
    response_class = input_options.delete(:response_class)

    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    output = @builder.send("collection_check_boxes",
      attribute_name, collection, value_method, label_method,
      input_options, merged_input_options,
      &collection_block_for_nested_boolean_style
    )
    output << @builder.text_field(response_class_to_method(response_class), merged_input_options.merge(class: 'form-control')) if %w(date datetime time float integer string).include?(response_class)
    output << @builder.text_area("text_value", merged_input_options.merge(class: 'form-control')) if response_class == "text"
    output
  end
  def response_class_to_method(type_sym)
    # doesn't handle response_class == answer, and doesn't have to
    "#{type_sym.to_s}_value".to_sym
  end
end