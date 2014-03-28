# http://www.elabs.se/blog/51-simple-tricks-to-clean-up-your-capybara-tests
module SurveyorFormMatchers
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
end