# http://www.elabs.se/blog/51-simple-tricks-to-clean-up-your-capybara-tests
require 'mustache'
module SurveyorUIHelpers
  def have_disabled_selected_radio(text)
    within("label", :text => text) do
      have_selector('input[type=radio][disabled=disabled]')
    end
  end
  def have_disabled_selected_checkbox(text)
    within("label", :text => text) do
      have_selector('input[type=checkbox][disabled=disabled]')
    end
  end
  def grid_row(text)
    find("fieldset.g_grid tr#q_#{Question.where(text: text).first.id}")
  end
  def question(reference_identifier, entry = nil)
    if entry
      find("fieldset#q_#{Question.where(reference_identifier: reference_identifier).first.id}_#{entry}")
    else
      find("fieldset#q_#{Question.where(reference_identifier: reference_identifier).first.id}")
    end
  end
  def have_hidden_question(reference_identifier, entry=nil)
    if entry
      have_css("fieldset#q_#{Question.where(reference_identifier: reference_identifier).first.id}_#{entry}.q_hidden")
    else
      have_css("fieldset#q_#{Question.where(reference_identifier: reference_identifier).first.id}.q_hidden")
    end

  end
  def have_hidden_group(reference_identifier, entry = nil)
    if entry
      have_css("fieldset#g_#{QuestionGroup.where(reference_identifier: reference_identifier).first.id}_#{entry}.g_hidden")
    else
      have_css("fieldset#g_#{QuestionGroup.where(reference_identifier: reference_identifier).first.id}.g_hidden")
    end
  end
  def group(reference_identifier)
    find("fieldset#g_#{QuestionGroup.where(reference_identifier: reference_identifier).first.id}")
  end
  def checkbox(q_ref_id, a_ref_id)
    find("input[value='#{Question.where(reference_identifier: q_ref_id).first.answers.where(reference_identifier: a_ref_id).first.id}']")
  end
  def start_survey(name, opts = {})
    visit(opts[:locale] ? "/surveys?locale=#{opts[:locale]}" : '/surveys')
    within "form", text: name do
      select(opts[:version], from: "version") if opts[:version]
      click_button I18n.t('surveyor.take_it')
    end
    return ResponseSet.where(access_code: current_path.split('/')[3]).first.extend ResponseSetTestingMethods
  end
  def the_15th
    Date.current.beginning_of_month + 14
  end

  def hash_context_module(hash)
    mod = Module.new
    mod.send(:define_method, :render_context) do
      return hash
    end
    return mod
  end
  def mustache_context_module(hash)
    context = Class.new(::Mustache)
    hash.each do |k,v|
      context.send(:define_method, k.to_sym) do
        v
      end
    end
    mod = Module.new
    mod.send(:define_method, :render_context) do
      context
    end
    return mod
  end
  def override_surveyor_helper_numbering
    SurveyorHelper.module_eval do
      def next_question_number(question)
        @letters ||= ("A".."Z").to_a
        @n ||= 25
        "<span class='qnum'>#{@letters[(@n += 1)%26]}. </span>"
      end
    end
  end
  def restore_surveyor_helper_numbering
    SurveyorHelper.module_eval do
      def next_question_number(question)
        @n ||= 0
        "<span class='qnum'>#{@n += 1}) </span>"
      end
    end
  end
end
module ResponseSetTestingMethods
  def for(q_ref_id, a_ref_id = nil)
    q = Question.where(reference_identifier: q_ref_id).first
    if a_ref_id
      a = Answer.where(reference_identifier: a_ref_id, question_id: q.id).first
      responses.where(question_id: q.id, answer_id: a.id)
    else
      responses.where(question_id: q.id)
    end
  end
  def count
    responses.count
  end
end