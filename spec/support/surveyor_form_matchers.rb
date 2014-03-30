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
  def start_survey(name)
    visit('/surveys') unless current_path == ('/surveys')
    within "form", text: name do
      click_button "Take it"
    end
    return ResponseSet.where(access_code: current_path.split('/')[3]).first
  end
  def start_versioned_survey(name, version)
    visit('/surveys') unless current_path == ('/surveys')
    within "form", text: name do
      select version, from: "version"
      click_button "Take it"
    end
    return ResponseSet.where(access_code: current_path.split('/')[3]).first
  end
  def start_translated_survey(name, locale)
    visit("/surveys?locale=#{locale}")
    within "form", text: name do
      click_button I18n.t('surveyor.take_it')
    end
    return ResponseSet.where(access_code: current_path.split('/')[3]).first
  end
end