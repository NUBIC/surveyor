require 'formtastic'
module Formtastic #:nodoc:
  class SemanticFormBuilder < ActionView::Helpers::FormBuilder
    def check_boxes_input(method, options)
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

        li_content = template.content_tag(:label,
          Formtastic::Util.html_safe("#{self.create_check_boxes(input_name, html_options, value, unchecked_value, hidden_fields)} #{escape_html_entities(label)}"),
          :for => input_id
        )

        li_options = value_as_class ? { :class => [method.to_s.singularize, value.to_s.downcase].join('_') } : {}
        template.content_tag(:li, Formtastic::Util.html_safe(li_content), li_options)
      end

      fieldset_content = legend_tag(method, options)
      # in order to get the naming right, send html options to the create_hidden_field method
      fieldset_content << self.create_hidden_field_for_check_boxes(input_name, html_options) unless hidden_fields
      # fieldset_content << self.create_hidden_field_for_check_boxes(input_name, value_as_class) unless hidden_fields
      fieldset_content << template.content_tag(:ol, Formtastic::Util.html_safe(list_item_content.join))
      template.content_tag(:fieldset, fieldset_content)
    end
    def create_hidden_field_for_check_boxes(input_name, html_options)
      # get the naming right
      template.hidden_field(input_name, '', html_options.merge(:value => ""))
      # options = value_as_class ? { :class => [method.to_s.singularize, 'default'].join('_') } : {}
      # input_name = "#{object_name}[#{method.to_s}][]"
      # template.hidden_field_tag(input_name, '', options)
    end
  end
end