require 'spec_helper'

describe "Surveyor UI interactions" do
  context "creation" do
    it "basic questions" do
    end
    it "default answers" do
    end
    it "quizzes" do
    end
    it "custom css class" do
    end
    it "a pick one question with an option for other" do
    end
    it "a repeater with a dropdown" do
    end
    it "a group with a dropdown" do
    end
    it "another pick one question with an option for other" do
    end
    it "checkboxes with text area" do
    end
    it "double letter rule keys" do
    end
    it "and changing dropdowns" do
    end
    it "a question with an option checkbox for other and text input" do
    end
    it "a question with an option checkbox for other and an empty text input" do
    end
    it "a question with an option radio button for other and text input" do
    end
    it "another question with an option radio button for other and text input" do
    end
    it "a question with mustache syntax" do
    end
    it "a question with mustache syntax" do
    end
    it "and saving grids" do
    end
    it "dates" do
    end
    it "a date using the js datepicker" do
    end
    it "images" do
    end
    it "and unchecking checkboxes" do
    end
  end
  it "accessing outdated survey" do
  end
  it "pick one and pick any with text areas" do
  end
  it "pick one and pick any with dates" do
  end
  it "dropdown within a group" do
  end
  it "multiple exclusive checkboxes" do
  end
  it "hidden questions for injecting data" do
  end
  it "hidden numbers" do
  end
  it "help text" do
  end
  it "labels in groups" do
  end
  it "dates in pick one" do
  end
  it "input mask and input mask placeholder" do
  end
  it "numeric input mask with alphanumeric input" do
  end
  it "alpha input mask with alphanumeric input" do
  end
  context "show" do
    include_context "favorites"
    include_context "feelings"
    it "takes a survey, then shows it" do
      visit('/surveys')
      within "form[action='/surveys/favorites']" do
        click_button "Take it"
      end
      expect(page).to have_content("What is your favorite color?")
      choose "red"
      choose "blue"
      check "orange"
      check "brown"
      click_button "Next section"
      click_button "Click here to finish"
      response_set = ResponseSet.last
      visit("/surveys/favorites/#{response_set.access_code}/")
      expect(page).to have_disabled_selected_radio("blue")
      expect(page).to have_disabled_selected_checkbox("orange")
      expect(page).to have_disabled_selected_checkbox("brown")
    end
    it "takes a survey with grid questions, then shows it" do
      visit('/surveys')
      within "form[action='/surveys/feelings']" do
        click_button "Take it"
      end
      expect(page).to have_content("Tell us how you feel today")
      within grid_row "anxious|calm" do
        choose "-1"
      end
      click_button "Click here to finish"
      response_set = ResponseSet.last
      visit("/surveys/favorites/#{response_set.access_code}/")
      within grid_row "anxious|calm" do
        expect(page).to have_disabled_selected_radio("-1")
      end
    end
  end
end