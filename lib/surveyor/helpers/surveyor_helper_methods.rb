# frozen_string_literal: true

module Surveyor
  module Helpers
    module SurveyorHelperMethods
      # Layout: stylsheets and javascripts
      def surveyor_includes
        stylesheet_link_tag('surveyor_all') + javascript_include_tag('surveyor_all')
      end

      def bootstrap_class_for(flash_type)
        case flash_type
        when :success
          'bg-success'
        when :error
          'bg-danger'
        when :alert
          'bg-warning'
        when :notice
          'bg-info'
        else
          flash_type.to_s
        end
      end

      # this helper references the instance variable @response_class
      def surveyor_tag_for(record, tag = nil, &block)
        tag ||= :div
        return if record.try(:display_type) == 'hidden'

        dom_classes = [dom_class(record),
                       record.try(:dom_class, @response_set),
                       ('row col-md-12' if (tag == :div) && (record.is_a?(QuestionGroup) || (record.is_a?(Question) && !record.part_of_group?)))].delete_if(&:blank?)
        content_tag(tag, { class: dom_classes.join(' '), id: dom_id(record) }, &block)
      end

      # Section: dependencies, menu, previous and next
      def dependency_explanation_helper(question, response_set)
        # Attempts to explain why this dependent question needs to be answered by referenced the dependent question and users response
        trigger_responses = []
        dependent_questions = Question.find_all_by_id(question.dependency.dependency_conditions.map(&:question_id)).uniq
        response_set.responses.find_all_by_question_id(dependent_questions.map(&:id)).uniq.each do |resp|
          trigger_responses << resp.to_s
        end
        "&nbsp;&nbsp;You answered &quot;#{trigger_responses.join('&quot; and &quot;')}&quot; to the question &quot;#{dependent_questions.map(&:text).join('&quot;,&quot;')}&quot;"
      end

      # these helpers references the instance variable @section
      def menu_button_for(section)
        current = section == @section
        submit_tag(section.translation(I18n.locale)[:title], name: "section[#{section.id}]", class: current ? 'btn btn-primary text-left' : 'btn btn-default text-left', disabled: current)
      end

      def previous_section(html_options = {})
        # use copy in memory instead of making extra db calls
        prev_index = [(@sections.index(@section) || 0) - 1, 0].max
        html_options = { class: 'btn btn-default' }.merge(html_options).merge(name: "section[#{@sections[prev_index].id}]")
        submit_tag(t('surveyor.previous_section').html_safe, html_options) unless @sections[0] == @section
      end

      def next_section(html_options = {})
        # use copy in memory instead of making extra db calls
        next_index = [(@sections.index(@section) || @sections.count) + 1, @sections.count].min
        html_options = { class: 'btn btn-primary' }.merge(html_options)
        @sections.last == @section ? submit_tag(t('surveyor.click_here_to_finish').html_safe, html_options.merge(name: 'finish')) : submit_tag(t('surveyor.next_section').html_safe, html_options.merge(name: "section[#{@sections[next_index].id}]"))
      end

      # questions and groups
      def q_text(q, context = nil, locale = nil)
        "#{next_question_number(q) unless q.dependent? || (q.display_type == 'label') || (q.display_type == 'image') || q.part_of_group?}#{q.text_for(nil, context, locale)}".html_safe
      end

      def g_text(g, _context = nil, _locale = nil)
        "#{next_question_number(g)}#{g.text_for(@render_context, I18n.locale)}".html_safe
      end

      def next_question_number(_question)
        @n ||= 0
        "<span class='qnum'>#{@n += 1}) </span>"
      end

      # Responses
      def rc_to_attr(type_sym)
        case type_sym.to_s
        when /^answer$/ then :answer_id
        else "#{type_sym}_value".to_sym
        end
      end

      def rc_to_as(type_sym)
        case type_sym.to_s
        when /(integer|float|date|time|datetime)/ then :string
        else type_sym
        end
      end

      def generate_pick_none_input_html(value, default_value, css_class, response_class, disabled, input_mask, input_mask_placeholder)
        html = {}
        html[:class] = [response_class, css_class].reject(&:blank?)
        html[:value] = value.blank? ? default_value : value
        html[:disabled] = disabled unless disabled.blank?
        if input_mask
          html[:'data-input-mask'] = input_mask
          html[:'data-input-mask-placeholder'] = input_mask_placeholder unless input_mask_placeholder.blank?
        end
        html
      end

      def data_attrs(answer)
        answer.input_mask ? answer.input_mask_placeholder ? { data: { input_mask: answer.input_mask, input_mask_placeholder: answer.input_mask_placeholder } } : { data: { input_mask: answer.input_mask } } : {}
      end

      # Responses
      def index(increment = true)
        @rc ||= 0
        (increment ? @rc += 1 : @rc).to_s
      end

      def r_for(response_set, question, answer = nil, response_group = nil)
        return nil unless response_set && question && question.id

        result = response_set.responses.detect do |r|
          (r.question_id == question.id) &&
                                          (answer.blank? or r.answer_id == answer.id) &&
                                          (response_group.blank? or r.response_group.to_i == response_group.to_i)
        end
        result || response_set.responses.build(question_id: question.id, response_group: response_group)
      end

      def answer_as(o, _group = nil)
        if o.is_a? Answer
          case o.response_class.to_s
          when /(integer|float|date|time|datetime)/ then :string
          else o.response_class
          end
        elsif o.is_a?(Question) && %w(one any).include?(o.try(:pick))
          o.pick == 'one' ? :radio_buttons_plus : :check_boxes_plus
        end
      end
    end
  end
end
