module Formtastic
  class SurveyorBuilder < SemanticFormBuilder
    def quiet_input(method, options = {})
      html_options = options.delete(:input_html) || strip_formtastic_options(options)
      html_options[:id] ||= generate_html_id(method, "")
      hidden_field(method, html_options)
    end
    def surveyor_check_boxes_input(method, options)
      collection = find_collection_for_column(method, options)
      html_options = options.delete(:input_html) || {}

      input_name      = generate_association_input_name(method)
      hidden_fields   = options.delete(:hidden_fields)
      value_as_class  = options.delete(:value_as_class)
      unchecked_value = options.delete(:unchecked_value) || ''
      html_options    = { :name => "#{@object_name}[#{input_name}][]" }.merge(html_options)
      input_ids       = []

      selected_values = find_selected_values_for_column(method, options)
      disabled_option_is_present = options.key?(:disabled)
      disabled_values = [*options[:disabled]] if disabled_option_is_present

      li_options = value_as_class ? { :class => [method.to_s.singularize, 'default'].join('_') } : {}

      list_item_content = collection.map do |c|
        label = c.is_a?(Array) ? c.first : c
        value = c.is_a?(Array) ? c.last : c
        input_id = generate_html_id(input_name, value.to_s.gsub(/\s/, '_').gsub(/\W/, '').downcase)
        input_ids << input_id

        html_options[:checked] = selected_values.include?(value)
        html_options[:disabled] = disabled_values.include?(value) if disabled_option_is_present
        html_options[:id] = input_id
        
        li_content = create_hidden_field_for_check_boxes(input_name, value_as_class) unless hidden_fields
        li_content << template.content_tag(:label,
          Formtastic::Util.html_safe("#{create_check_boxes(input_name, html_options, value, unchecked_value, hidden_fields)} #{escape_html_entities(label)}"),
          :for => input_id
        )
        li_content << basic_input_helper(:text_field, :string, :string_value, options) if options[:response_class] == "other_and_string"
        li_content << basic_input_helper(:text_field, :string, :string_value, options) if %w(string other_and_string).include?(options[:response_class])

        # li_options = value_as_class ? { :class => [method.to_s.singularize, value.to_s.downcase].join('_') } : {}
        Formtastic::Util.html_safe(li_content)
      end

      Formtastic::Util.html_safe(list_item_content.join)
    end
    def surveyor_radio_input(method, options)
      collection   = find_collection_for_column(method, options)
      html_options = strip_formtastic_options(options).merge(options.delete(:input_html) || {})

      input_name = generate_association_input_name(method)
      value_as_class = options.delete(:value_as_class)
      input_ids = []

      list_item_content = collection.map do |c|
        label = c.is_a?(Array) ? c.first : c
        value = c.is_a?(Array) ? c.last  : c
        input_id = generate_html_id(input_name, value.to_s.gsub(/\s/, '_').gsub(/\W/, '').downcase)
        input_ids << input_id

        html_options[:id] = input_id

        li_content = template.content_tag(:label,
          Formtastic::Util.html_safe("#{radio_button(input_name, value, html_options)} #{escape_html_entities(label)}"),
          :for => input_id
        )
        
        li_content << basic_input_helper(:text_field, :string, :integer_value, options) if options[:response_class] == 'integer'
        li_content << basic_input_helper(:text_field, :string, :string_value, options) if options[:response_class] == 'string'

        # li_options = value_as_class ? { :class => [method.to_s.singularize, value.to_s.downcase].join('_') } : {}
        Formtastic::Util.html_safe(li_content)
      end

      Formtastic::Util.html_safe(list_item_content.join)
    end
    def date_input(method, options)
      string_input(method, options)
    end
  end
end
