require 'surveyor/helpers/asset_pipeline'

module Surveyor
  module Helpers
    module SurveyorHelperMethods
      include AssetPipeline

      # Layout: stylsheets and javascripts
      def surveyor_includes
        if asset_pipeline_enabled?
          stylesheet_link_tag('surveyor_all') + javascript_include_tag('surveyor_all')
        else
          stylesheet_link_tag('surveyor/reset', 'surveyor/dateinput', 'surveyor/jquery-ui.custom', 'surveyor/jquery-ui-timepicker-addon', 'surveyor', 'custom') + javascript_include_tag('surveyor/jquery.tools.min', 'surveyor/jquery-ui', 'surveyor/jquery-ui-timepicker-addon', 'surveyor/jquery.surveyor')
        end
      end
      # Helper for displaying warning/notice/error flash messages
      def flash_messages(types)
        types.map{|type| content_tag(:div, "#{flash[type]}".html_safe, :class => type.to_s)}.join.html_safe
      end
      # Section: dependencies, menu, previous and next
      def dependency_explanation_helper(question,response_set)
        # Attempts to explain why this dependent question needs to be answered by referenced the dependent question and users response
        trigger_responses = []
        dependent_questions = Question.find_all_by_id(question.dependency.dependency_conditions.map(&:question_id)).uniq
        response_set.responses.find_all_by_question_id(dependent_questions.map(&:id)).uniq.each do |resp|
          trigger_responses << resp.to_s
        end
        "&nbsp;&nbsp;You answered &quot;#{trigger_responses.join("&quot; and &quot;")}&quot; to the question &quot;#{dependent_questions.map(&:text).join("&quot;,&quot;")}&quot;"
      end
      def menu_button_for(section)
        submit_tag(section.title, :name => "section[#{section.id}]")
      end
      def previous_section
        # use copy in memory instead of making extra db calls
        submit_tag(t('surveyor.previous_section').html_safe, :name => "section[#{@sections[@sections.index(@section)-1].id}]") unless @sections.first == @section
      end
      def next_section
        # use copy in memory instead of making extra db calls
        @sections.last == @section ? submit_tag(t('surveyor.click_here_to_finish').html_safe, :name => "finish") : submit_tag(t('surveyor.next_section').html_safe, :name => "section[#{@sections[@sections.index(@section)+1].id}]")
      end

      # Questions
      def q_text(obj, context=nil)

        return image_tag(obj.text) if obj.is_a?(Question) and obj.display_type == "image"
        return obj.render_question_text(context) if obj.is_a?(Question) and (obj.dependent? or obj.display_type == "label" or obj.part_of_group?)
        "#{next_question_number(obj)}#{obj.render_question_text(context)}"
      end

      def next_question_number(question)
        @n ||= 0
        "<span class='qnum'>#{@n += 1}) </span>"
      end

      # def split_text(text = "") # Split text into with "|" delimiter - parts to go before/after input element
      #   {:prefix => text.split("|")[0].blank? ? "&nbsp;" : text.split("|")[0], :postfix => text.split("|")[1] || "&nbsp;"}
      # end
      # def question_help_helper(question)
      #   question.help_text.blank? ? "" : %Q(<span class="question-help">#{question.help_text}</span>)
      # end

      # Help_text
      def render_help_text(obj, context=nil)
        obj.render_help_text(context)
      end

      # Answers
      def a_text(obj, pos=nil, context = nil)
        return image_tag(obj.text) if obj.is_a?(Answer) and obj.display_type == "image"
        obj.split_or_hidden_text(pos, context)
      end

      def rc_to_attr(type_sym)
        case type_sym.to_s
        when /^answer$/ then :answer_id
        else "#{type_sym.to_s}_value".to_sym
        end
      end

      def rc_to_as(type_sym)
        case type_sym.to_s
        when /(integer|float|date|time|datetime)/ then :string
        else type_sym
        end
      end

      def generate_pick_none_input_html(value, default_value, css_class, response_class, disabled)
        html = {}
        html[:class] = [response_class,css_class].reject{ |c| c.blank? }
        html[:value] = default_value if value.blank?
        html[:disabled] = disabled unless disabled.blank?
        html
      end

      # Responses
      def response_for(response_set, question, answer = nil, response_group = nil)
        return nil unless response_set && question && question.id
        result = response_set.responses.detect{|r| (r.question_id == question.id) && (answer.blank? ? true : r.answer_id == answer.id) && (r.response_group.blank? ? true : r.response_group.to_i == response_group.to_i)}
        result.blank? ? response_set.responses.build(:question_id => question.id, :response_group => response_group) : result
      end
      def response_idx(increment = true)
        @rc ||= 0
        (increment ? @rc += 1 : @rc).to_s
      end
    end
  end
end
