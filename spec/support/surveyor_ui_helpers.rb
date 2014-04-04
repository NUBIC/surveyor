# http://www.elabs.se/blog/51-simple-tricks-to-clean-up-your-capybara-tests
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
  def group(reference_identifier)
    find("fieldset#g_#{QuestionGroup.where(reference_identifier: reference_identifier).first.id}")
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