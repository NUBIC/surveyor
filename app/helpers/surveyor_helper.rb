module SurveyorHelper

  # Layout: stylsheets and javascripts
  def surveyor_includes
    surveyor_stylsheets + surveyor_javascripts    
  end
  def surveyor_stylsheets
    stylesheet_link_tag 'surveyor/reset', 'surveyor', 'surveyor/ui.theme.css','surveyor/jquery-ui-slider-additions'
  end
  def surveyor_javascripts
    javascript_include_tag 'surveyor/jquery-1.2.6.js', 'surveyor/jquery-ui-personalized-1.5.3.js', 'surveyor/accessibleUISlider.jQuery.js','surveyor/jquery.form.js', 'surveyor/surveyor.js'
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
    # submit_tag("#{t ('surveyor.previous_section')} &raquo;", :name => "section[#{@section.previous.id}]") unless @section.previous.nil?
    # refactored to use copy in memory instead of making extra db calls
    submit_tag(t('surveyor.previous_section'), :name => "section[#{@sections[@sections.index(@section)-1].id}]") unless @sections.first == @section
  end
  def next_section
    # @section.next.nil? ? submit_tag(t ('surveyor.click_here_to_finish'), :name => "finish") : submit_tag("Next section &laquo;", :name => "section[#{@section.next.id}]")
    # refactored to use copy in memory instead of making extra db calls
    @sections.last == @section ? submit_tag(t('surveyor.click_here_to_finish'), :name => "finish") : submit_tag(t('surveyor.next_section'), :name => "section[#{@sections[@sections.index(@section)+1].id}]")
  end
  
  # Questions
  def next_number
    @n ||= 0
    "#{@n += 1}<span style='padding-left:0.1em;'>)</span>"
  end
  def split_text(text = "") # Split text into with "|" delimiter - parts to go before/after input element
    {:prefix => text.split("|")[0].blank? ? "&nbsp;" : text.split("|")[0], :postfix => text.split("|")[1] || "&nbsp;"}
  end
  def question_help_helper(question)
    question.help_text.blank? ? "" : %Q(<span class="question-help">#{question.help_text}</span>)
  end

  # Answers
  def fields_for_response(response, response_group = nil, &block)
    name = response_group.nil? ? "responses[#{response.question_id}][#{response.answer_id}]" : "response_groups[#{response.question_id}][#{response_group}][#{response.answer_id}]"
    fields_for(name, response, :builder => SurveyFormBuilder, &block)
  end
  def fields_for_radio(response, &block)
    fields_for("responses[#{response.question_id}]", response, :builder => SurveyFormBuilder, &block)
  end
  
end
