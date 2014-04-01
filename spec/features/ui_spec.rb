require 'spec_helper'

describe "ui interactions" do
  context "saves responses" do
    include_context "everything"
    it "radio button" do
      response_set = start_survey('Everything')
      expect(page).to have_content("What is your favorite color?")
      within question("1") do
        choose "red"
        choose "blue"
      end
      click_button "Next section"
      expect(response_set.count).to eq(1)
    end
    it "dropdown" do
      response_set = start_survey('Everything')
      expect(page).to have_content("What color is the sky right now?")
      within question("3") do
        select "sunset red", from: "What color is the sky right now?"
      end
      click_button "Next section"
      expect(response_set.count).to eq(1)
      expect(response_set.for("3", "sr").count).to eq(1)
      click_button "Previous section"
      within question("3") do
        select "night black", from: "What color is the sky right now?"
      end
      click_button "Next section"
      expect(response_set.count).to eq(1)
      expect(response_set.for("3", "nb").count).to eq(1)
    end
    it "check and uncheck checkboxes" do
      response_set = start_survey('Everything')
      expect(page).to have_content("What color is the sky right now?")
      check "orange"
      click_button "Next section"
      expect(response_set.count).to eq(1)
      click_button "Previous section"
      uncheck "orange"
      click_button "Next section"
      expect(response_set.count).to eq(0)
    end
    it "string" do
      # fill in other string
    end
    it "free text" do
    end
    it "radio button with string and free text" do
      # #236 - ":text"- field doesn't show up in the multi-select questions
      # #234 - It's possible to enter the value without selecting a radiobutton
    end
    it "checkbox with string and free text" do
      # #236 - ":text"- field doesn't show up in the multi-select questions
      # #234 - It's possible to enter the value without selecting a radiobutton
    end
    it "date" do
      # go away, come back, see same values, change them, come back
    end
    it "datetime" do
    end
    it "time" do
    end
    it "date with js datepicker" do
      # select a date in the datepicker
    end
    it "radio button and checkbox with date" do
        # Issue 207 - Create separate fields for date and time
    end
    it "slider" do
    end
  end
  context "saves group responses" do
    it "grid" do
      # select something in a grid, go away, come back
      # feelings
    end
    it "repeater" do
    end
    it "group with a dropdown" do
      # a non-repeater group with a dropdown
      # #251 Dropdowns inside of group display as radio buttons
    end
    it "group repeater with a dropdown" do
      # favorites
    end
    it "group with labels" do
    end
  end
  context "dependencies" do
    it "double letter rule keys" do
      # for a dependency - try this with "lifestyle"
    end
    it "simple" do
    end
    it "inside a group" do
    end
    it "inside an inline group" do
    end
    it "groups" do
    end
    it "on question in dependent group" do
    end
    it "with != on questions without responses" do
    end
    it "with != on questions without responses" do
    end
    it "count== dependencies" do
    end
    it "when the last response is removed" do
    end
    it "within groups" do
    end
    it "on multi-select (from the kitchen sink)" do
    end
  end
  context "special features" do
    it "help text" do
      # add help text to a survey
    end
    it "images" do
      # see images
    end
    it "custom css class" do
      # check custom css class in UI
    end
    it "default answer" do
      # open survey, default response should be created
    end
    it "multiple exclusive checkboxes" do
    end
    it "hidden questions" do
        # #197 - Add a hidden field type, don't show hidden questions and groups in the DOM
        #        don't use up question numbers on them either. custom class "hidden" doesn't
        #        do anything until you add your own css to hide it
    end
    it "customizing numbering" do
    end
    it "mustache syntax" do
      # Issue 259 - substitution of the text with Mustache
    end
    it "mustache with simple hash context" do
      # Issue 296 - Mustache rendering doesn't work with simple hash contexts
    end
    it "input mask and placeholder" do
    end
    it "numeric input mask with alphanumeric input" do
    end
    it "alpha input mask with alphanumeric input" do
    end
  end
  context "versioning" do
    include_context "favorites"
    include_context "favorites-ish"
    it "takes current survey" do
      response_set = start_survey('Favorites')
      expect(page).to have_content("What is your favorite color?")
      expect(page).to have_content("redish")
      choose "blueish"
      choose "redish"
      click_button "Next section"
      click_button "Click here to finish"
      expect(response_set.count).to eq(1)
    end
    it "takes previous survey" do
      response_set = start_survey('Favorites', version: '0')
      expect(page).to have_content("What is your favorite color?")
      expect(page).to have_content("red")
      choose "red"
      choose "blue"
      click_button "Next section"
      click_button "Click here to finish"
      expect(response_set.count).to eq(1)
    end
  end
  context "shows responses" do
    include_context "favorites"
    include_context "feelings"
    it "takes a survey, then shows it" do
      response_set = start_survey('Favorites')
      expect(page).to have_content("What is your favorite color?")
      choose "red"
      choose "blue"
      check "orange"
      check "brown"
      click_button "Next section"
      click_button "Click here to finish"
      visit("/surveys/favorites/#{response_set.access_code}/")
      expect(page).to have_disabled_selected_radio("blue")
      expect(page).to have_disabled_selected_checkbox("orange")
      expect(page).to have_disabled_selected_checkbox("brown")
    end
    it "takes a survey with grid questions, then shows it" do
      response_set = start_survey('Feelings')
      expect(page).to have_content("Tell us how you feel today")
      within grid_row "anxious|calm" do
        choose "-1"
      end
      click_button "Click here to finish"
      visit("/surveys/favorites/#{response_set.access_code}/")
      within grid_row "anxious|calm" do
        expect(page).to have_disabled_selected_radio("-1")
      end
    end
  end
end