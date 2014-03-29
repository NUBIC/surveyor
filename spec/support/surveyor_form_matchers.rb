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
  def start_survey(slug)
    visit('/surveys') unless current_path == ('/surveys')
    within "form[action='/surveys/#{slug}']" do
      click_button "Take it"
    end
  end
  def start_translated_survey(slug, locale)
    visit("/surveys?locale=#{locale}") unless current_path == ('/surveys')
    if locale == I18n.default_locale.to_s
      within "form[action='/surveys/#{slug}']" do
        click_button I18n.t('surveyor.take_it')
      end
    else
      within "form[action='/surveys/#{slug}?locale=#{locale}']" do
        click_button I18n.t('surveyor.take_it')
      end
    end

  end
end