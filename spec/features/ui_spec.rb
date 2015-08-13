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
      response_set = start_survey('Everything')
      expect(page).to have_content("What is the best color for a fire engine?")
      within question("fire_engine") do
        fill_in "Color", with: "red"
      end
      click_button "Next section"
      expect(response_set.count).to eq(1)
      expect(response_set.for("fire_engine", "color").first.string_value).to eq("red")
    end
    it "free text" do
      response_set = start_survey('Everything')
      expect(page).to have_content("Please compose a poem about a color")
      within question("color_poem") do
        fill_in "Poem", with: "green, nature's color, you're not easy, but that's why you're worth it"
      end
      click_button "Next section"
      expect(response_set.count).to eq(1)
      expect(response_set.for("color_poem", "poem_text").first.text_value).to eq("green, nature's color, you're not easy, but that's why you're worth it")
    end
    it "date" do
      response_set = start_survey('Everything')
      expect(page).to have_content("When is the next color run?")
      within question("color_run_date") do
        fill_in "On", with: "2014-06-08"
      end
      click_button "Next section"
      expect(response_set.count).to eq(1)
      expect(response_set.for("color_run_date", "date").first.date_value).to eq("2014-06-08")
    end
    it "time" do
      response_set = start_survey('Everything')
      expect(page).to have_content("What time does it start?")
      within question("color_run_time") do
        fill_in "At", with: "1:30am"
      end
      click_button "Next section"
      expect(response_set.count).to eq(1)
      expect(response_set.for("color_run_time", "time").first.time_value).to eq("01:30")
    end
    it "datetime" do
      response_set = start_survey('Everything')
      expect(page).to have_content("When is your next hair color appointment?")
      within question("hair_appointment") do
        fill_in "At", with: "2014-06-08 17:00:00"
      end
      click_button "Next section"
      expect(response_set.count).to eq(1)
      expect(response_set.for("hair_appointment", "datetime").first.datetime_value).to eq(Time.zone.parse("2014-06-08 17:00:00"))
    end
    it "radio button with date" do
      pending "better selectors"
      # Issue 207 - Create separate fields for date and time
      response_set = start_survey('Everything')
      expect(page).to have_content("What is your birth date?")
      within question("birth_date") do
        choose "I was born on"
        fill_in "I was born on", with: "2000-01-01"
      end
      click_button "Next section"
      expect(response_set.count).to eq(1)
      expect(response_set.for("birth_date", "date").first.date_value).to eq("2000-01-01")
    end
    it "checkbox with date" do
      pending "better selectors"
      # Issue 207 - Create separate fields for date and time
      response_set = start_survey('Everything')
      expect(page).to have_content("What is your birth date?")
      within question("birth_time") do
        choose "I was born at"
        fill_in "I was born at", with: "12:01am"
      end
      click_button "Next section"
      expect(response_set.count).to eq(1)
      expect(response_set.for("birth_time", "time").first.date_value).to eq("00:01")
    end
    it "slider" do
      pending "move slider programmatically"
    end
  end
  context "saves group responses" do
    include_context "everything"
    it "grid" do
      response_set = start_survey('Everything')
      click_button "Groups"
      expect(page).to have_content("How interested are you in the following?")
      within( grid_row("weddings")){ choose "interested" }
      click_button "Next section"
      expect(response_set.count).to eq(1)
    end
    it "repeater, repeater with a dropdown" do
      response_set = start_survey('Everything')
      click_button "Groups"
      expect(page).to have_content("Tell us about your family")
      within group("family") do
        select "Parent", from: "Relation"
        fill_in "Name", with: "Mom"
        fill_in "Quality of your relationship", with: "great"
      end
      click_button "Next section"
      click_button "Previous section"
      within group("family") do
        within( question("relation", 1)){ select "Parent", from: "Relation" }
        within( question("name", 1)){ fill_in "Name", with: "Dad" }
        within( question("quality", 1)){ fill_in "Quality of your relationship", with: "great" }
      end
      click_button "Next section"
      expect(response_set.count).to eq(6)
    end
    it "group with a dropdown" do
      # Issue 251 - Dropdowns inside of group display as radio buttons
      response_set = start_survey('Everything')
      click_button "Groups"
      expect(page).to have_content("Drop it like it's hot")
      within group("drop_it") do
        select "It", from: "What to drop"
      end
      click_button "Next section"
      expect(response_set.count).to eq(1)
    end
    it "group with labels" do
      response_set = start_survey('Everything')
      click_button "Groups"
      expect(page).to have_content("Drop it like it's hot")
      within group("drop_it") do
        expect(page).to have_content("Like Snoop Dogg said")
      end
    end
  end
  context "dependencies" do
    include_context "everything"
    it "double letter rule keys" do
      # for a dependency - try this with "lifestyle"
    end
    it "simple" do
    end
    it "inside a group" do
      response_set = start_survey('Everything')
      click_button "Dependencies"
      expect(page).to have_hidden_question('who')
      expect(page).to have_hidden_question('weird')
      within question("anybody") do
        choose "Yes"
      end
      click_button "Next section"
      click_button "Previous section"
      expect(page).to_not have_hidden_question('who')
      expect(page).to have_hidden_question('weird')
      within question("anybody") do
        choose "No"
      end
      click_button "Next section"
      click_button "Previous section"
      expect(page).to have_hidden_question('who')
      expect(page).to_not have_hidden_question('weird')

    end
    it "groups" do
      response_set = start_survey('Everything')
      click_button "Dependencies"
      expect(page).to have_hidden_group('anybody_no')
      within question("anybody") do
        choose "No"
      end
      click_button "Next section"
      click_button "Previous section"
      expect(page).to_not have_hidden_group('anybody_no')
    end
    it "on question in dependent group" do
      response_set = start_survey('Everything')
      click_button "Dependencies"
      expect(page).to have_hidden_question('feels_like_it')
      within question("anybody") do
        choose "No"
      end
      click_button "Next section"
      click_button "Previous section"
      expect(page).to have_hidden_question('feels_like_it')
      within question("who_talking") do
        choose "Are you nuts?"
      end
      click_button "Next section"
      click_button "Previous section"
      expect(page).to_not have_hidden_question('feels_like_it')
    end
    it "!= without responses" do
      # Issue 337 answer != condition returns false if question was never activated
      response_set = start_survey('Everything')
      click_button "Dependencies"
      expect(page).to have_content("How do you cool your home?")
      expect(page).to_not have_hidden_question('cooling_2')
      expect(page).to have_content("How much does it cost to run your non-passive cooling solutions?")
      within question("cooling_1") do
        choose "Passive"
      end
      click_button "Next section"
      click_button "Previous section"
      expect(page).to have_hidden_question('cooling_2')
    end
    it "!= without responses, count>0" do
      # Issue 337 answer != condition returns false if question was never activated
      response_set = start_survey('Everything')
      click_button "Dependencies"
      expect(page).to have_content("How do you heat your home?")
      expect(page).to have_hidden_question('heating_2')
      expect(page).to have_content("How much does it cost to run your non-passive heating solutions?")
      within question("heating_1") do
        check "Oven"
      end
      click_button "Next section"
      click_button "Previous section"
      expect(page).to_not have_hidden_question('heating_2')
    end
    it "count== dependencies" do
      response_set = start_survey('Everything')
      click_button "Dependencies"
      expect(page).to have_content("How many times do you count a day")
      expect(page).to have_hidden_question('counts_good')
      expect(page).to have_hidden_question('counts_twice')

      within question("counts") do
        check "Once for me"
      end
      click_button "Next section"
      click_button "Previous section"
      expect(page).to_not have_hidden_question('counts_good')
      expect(page).to have_hidden_question('counts_twice')

      within question("counts") do
        check "Once for you"
      end
      click_button "Next section"
      click_button "Previous section"
      expect(page).to have_hidden_question('counts_good')
      expect(page).to_not have_hidden_question('counts_twice')
    end
    it "when the last response is removed" do
      response_set = start_survey('Everything')
      click_button "Dependencies"
      expect(page).to have_content("How do you heat your home?")
      expect(page).to have_hidden_question('heating_3')

      within question("heating_1") do
        check "Forced air"
      end
      click_button "Next section"
      click_button "Previous section"
      expect(page).to_not have_hidden_question('heating_3')

      within question("heating_1") do
        uncheck "Forced air"
      end
      click_button "Next section"
      click_button "Previous section"
      expect(page).to have_hidden_question('heating_3')
    end
    it "on checkboxes" do
      response_set = start_survey('Everything')
      click_button "Dependencies"
      expect(page).to have_content("How many times do you count a day")
      expect(page).to have_hidden_question('thanks_counting')
      expect(page).to have_hidden_question('yay_everyone')
      within question("counts") do
        check "Once for me"
      end
      click_button "Next section"
      click_button "Previous section"
      expect(page).to_not have_hidden_question('thanks_counting')
      expect(page).to have_hidden_question('yay_everyone')

      within question("counts") do
        check "Once for you"
      end
      click_button "Next section"
      click_button "Previous section"
      expect(page).to_not have_hidden_question('thanks_counting')
      expect(page).to have_hidden_question('yay_everyone')

      within question("counts") do
        check "Once for everyone"
      end
      click_button "Next section"
      click_button "Previous section"
      expect(page).to_not have_hidden_question('thanks_counting')
      expect(page).to_not have_hidden_question('yay_everyone')
    end
  end
  context "special features" do
    include_context "everything"
    it "help text" do
      response_set = start_survey('Everything')
      click_button "Special"
      within question("favorite_food") do
        expect(page).to have_css("span.help", text: "just say beef")
      end
    end
    it "images" do
      response_set = start_survey('Everything')
      click_button "Special"
      within question("which_way") do
        expect(page).to have_css('img[src^="/assets/surveyor/next.gif"]')
        expect(page).to have_css('img[src^="/assets/surveyor/prev.gif"]')
      end
    end
    it "custom css class" do
      response_set = start_survey('Everything')
      click_button "Special"
      expect(page).to have_css("fieldset.q_default.hidden")
    end
    it "default answer" do
      response_set = start_survey('Everything')
      click_button "Special"
      click_button "Click here to finish"
      expect(response_set.count).to eq(1)
      expect(response_set.for("favorite_food", "food").first.string_value).to eq("beef")
    end
    it "hidden questions" do
      # Issue 197 - Add a hidden field type
      # does not appear in DOM, does not receive question numering
      response_set = start_survey('Everything')
      click_button "Special"
      expect(page).to_not have_content("What is your name?")
      expect(page).to_not have_content("Friends")
      expect(page).to_not have_content("Who are your friends?")
      # custom class "hidden" does nothing unless you add your own css to hide it
      expect(page).to have_content("5) What is your favorite number?")
    end
    it "customizing numbering" do
      override_surveyor_helper_numbering
      response_set = start_survey('Everything')
      expect(page).to have_content("A. What is your favorite color?")
      expect(page).to have_content("B. Choose the colors you don't like")
      expect(page).to have_content("C. What color is the sky right now?")
      expect(page).to have_content("D. What is the best color for a fire engine?")
      expect(page).to have_content("E. What was the last room you painted, and what color?")
      restore_surveyor_helper_numbering
    end
    it "mustache syntax" do
      # Issue 259 - substitution of the text with Mustache
      SurveyorController.send(:include, mustache_context_module(name: "Santa", thing: "beards"))
      response_set = start_survey('Everything')
      click_button "Special"
      expect(page).to have_content("Regarding Santa")
      expect(page).to have_content("Answer all you know about Santa")
      expect(page).to have_content("Where does Santa live?")
      expect(page).to have_content("If you don't know where Santa lives, skip the question")
      expect(page).to have_content("Santa lives on North Pole")
      expect(page).to have_content("Santa lives on South Pole")
      expect(page).to have_content("Santa doesn't exist")
      expect(page).to have_content("Now think about beards")
      expect(page).to have_content("Yes, beards")
    end
    it "mustache with simple hash context" do
      # Issue 296 - Mustache rendering doesn't work with simple hash contexts
      SurveyorController.send(:include, hash_context_module({name: "Father Christmas", thing: "reindeer"}))
      response_set = start_survey('Everything')
      click_button "Special"
      expect(page).to have_content("Regarding Father Christmas")
      expect(page).to have_content("Answer all you know about Father Christmas")
      expect(page).to have_content("Where does Father Christmas live?")
      expect(page).to have_content("If you don't know where Father Christmas lives, skip the question")
      expect(page).to have_content("Father Christmas lives on North Pole")
      expect(page).to have_content("Father Christmas lives on South Pole")
      expect(page).to have_content("Father Christmas doesn't exist")
      expect(page).to have_content("Now think about reindeer")
      expect(page).to have_content("Yes, reindeer")
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