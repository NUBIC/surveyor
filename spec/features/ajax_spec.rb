require 'spec_helper'

describe "saving with ajax", js: true do
  include_context "everything"
  it "saves a simple radio button response" do
    response_set = start_survey('Everything')
    expect(page).to have_content("What is your favorite color?")
    within question("1") do
      choose "red"
    end
    wait_for_ajax
    expect(response_set.count).to eq(1)
    expect(response_set.for("1", "r").count).to eq(1)
  end
  it "saves a simple checkbox response" do
    response_set = start_survey('Everything')
    expect(page).to have_content("Choose the colors you don't like")
    within question("2b") do
      check "purple"
    end
    wait_for_ajax
    expect(response_set.count).to eq(1)
    expect(response_set.for("2b", "2").count).to eq(1)
  end
  it "saves a radio button plus string response" do
    response_set = start_survey('Everything')
    expect(page).to have_content("What is your favorite color?")
    within question("1") do
      find("input[id$='string_value']").set("black")
    end
    wait_for_ajax
    expect(response_set.count).to eq(1)
    expect(response_set.for("1", "other").first.string_value).to eq("black")
  end
  it "radio button with string and free text" do
    # #236 - ":text"- field doesn't show up in the multi-select questions
    # #234 - It's possible to enter the value without selecting a radiobutton
    pending "better selectors"
    response_set = start_survey('Everything')
    expect(page).to have_content("What was the last room you painted, and what color?")
    save_and_open_page
    within question("last_room") do
      fill_in "kitchen", with: "yellow"
    end
    wait_for_ajax
    expect(response_set.count).to eq(1)
    expect(response_set.for("last_room", "kitchen").first.string_value).to eq("yellow")
    within question("last_room") do
      fill_in "other", with: "living room, white"
    end
    expect(response_set.count).to eq(1)
    expect(response_set.for("last_room", "other").first.text_value).to eq("living room, white")
  end
  it "checkbox with string and free text" do
    # #236 - ":text"- field doesn't show up in the multi-select questions
    # #234 - It's possible to enter the value without selecting a radiobutton
    pending "better selectors"
    response_set = start_survey('Everything')
    expect(page).to have_content("What rooms have you painted, and what color?")
    save_and_open_page
    within question("last_room") do
      fill_in "kitchen", with: "yellow"
      fill_in "other", with: "living room, white"
    end
    wait_for_ajax
    expect(response_set.count).to eq(2)
    expect(response_set.for("last_room", "kitchen").first.string_value).to eq("yellow")
    expect(response_set.for("last_room", "other").first.text_value).to eq("living room, white")
  end
  it "saves a string response" do
    response_set = start_survey('Everything')
    expect(page).to have_content("What is the best color for a fire engine?")
    within question("fire_engine") do
      fill_in "Color", with: "red"
    end
    wait_for_ajax
    expect(response_set.count).to eq(1)
    expect(response_set.for("fire_engine", "color").first.string_value).to eq("red")
  end
  it "saves a free text response" do
    response_set = start_survey('Everything')
    expect(page).to have_content("Please compose a poem about a color")
    within question("color_poem") do
      fill_in "Poem", with: "green, nature's color, you're not easy, but that's why you're worth it"
    end
    wait_for_ajax
    expect(response_set.count).to eq(1)
    expect(response_set.for("color_poem", "poem_text").first.text_value).to eq("green, nature's color, you're not easy, but that's why you're worth it")
  end

  it "saves a date response" do
    response_set = start_survey('Everything')
    q = question("color_run_date")
    page.execute_script %Q{ $('##{q[:id]} input.date').trigger("focus") } # activate datetime picker
    page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15
    wait_for_ajax
    expect(response_set.count).to eq(1)
    expect(response_set.for("color_run_date", "date").first.date_value).to eq(the_15th.to_s)
  end
  it "saves a time response" do
    pending "a bettter time picker"
    # response_set = start_survey('Everything')
    # expect(page).to have_content("What time does it start?")
    # q = question("color_run_time")
    # page.execute_script %Q{ $('##{q[:id]} input.time').trigger("focus") } # activate datetime picker
    # page.execute_script %Q{ $('button.ui-datepicker-close').trigger('click') } # close datetime picker
    # page.execute_script %Q{ $('##{q[:id]} input.time').trigger("change") } # activate datetime picker
    # wait_for_ajax
    # expect(response_set.count).to eq(1)
    # expect(response_set.for("color_run_time", "datetime").first.time_value).to eq("#{the_15th.to_s} 00:00:00")
  end
  it "saves a datetime response" do
    pending "a bettter datetime picker"
    # response_set = start_survey('Everything')
    # expect(page).to have_content("When is your next hair color appointment?")
    # q = question("hair_appointment")
    # page.execute_script %Q{ $('##{q[:id]} input.datetime').trigger("focus") } # activate datetime picker
    # page.execute_script %Q{ $("a.ui-state-default:contains('15')").trigger("click") } # click on day 15
    # page.execute_script %Q{ $('button.ui-datepicker-close').trigger('click') } # close datetime picker
    # page.execute_script %Q{ $('##{q[:id]} input.time').trigger("change") } # activate datetime picker
    # wait_for_ajax
    # expect(response_set.count).to eq(1)
    # expect(response_set.for("hair_appointment", "datetime").first.datetime_value).to eq("11:45:00")
  end
  it "saves a slider response" do
    pending "move slider programmatically"
  end
  it "saves a grid response" do
    # #339 - Grid question responses fail to store via JavaScript
    response_set = start_survey('Everything')
    click_button "Groups"
    expect(page).to have_content("How interested are you in the following?")
    within( grid_row("weddings")){ choose "interested" }
    wait_for_ajax
    expect(response_set.count).to eq(1)
  end
  it "saves a repeater response" do
    response_set = start_survey('Everything')
    click_button "Groups"
    expect(page).to have_content("Tell us about your family")
    within group("family") do
      select "Parent", from: "Relation"
      fill_in "Name", with: "Mom"
      fill_in "Quality of your relationship", with: "great"
      click_button "+ add row"
      within( question("relation", 1)){ select "Parent", from: "Relation" }
      within( question("name", 1)){ fill_in "Name", with: "Dad" }
      within( question("quality", 1)){ fill_in "Quality of your relationship", with: "great" }
    end
    wait_for_ajax
    expect(response_set.count).to eq(6)
  end
  it "input mask and placeholder" do
    response_set = start_survey('Everything')
    click_button "Special"
    expect(page).to have_content("What is your home phone number?")
    within question("home_phone") do
      fill_in "phone", with: "1234567890"
    end
    wait_for_ajax
    expect(response_set.count).to eq(1)
    expect(response_set.for("home_phone", "hm_phone").first.string_value).to eq("(123)456-7890")
  end
  it "numeric input mask with alphanumeric input" do
    response_set = start_survey('Everything')
    click_button "Special"
    expect(page).to have_content("What is your cell phone number?")
    within question("cell_phone") do
      fill_in "phone", with: "1a2b3c4d5e6f7g8h9i0"
    end
    wait_for_ajax
    expect(response_set.count).to eq(1)
    expect(response_set.for("cell_phone", "cl_phone").first.string_value).to eq("(123)456-7890")
  end
  it "alpha input mask with alphanumeric input" do
    response_set = start_survey('Everything')
    click_button "Special"
    expect(page).to have_content("What is your home phone number?")
    within question("favorite_letters") do
      fill_in "letters", with: "1a2b3c4d5e6f7g8h9i0"
    end
    wait_for_ajax
    expect(response_set.count).to eq(1)
    expect(response_set.for("favorite_letters", "fav_letters").first.string_value).to eq("abcdefghi")
  end
  it "multiple exclusive checkboxes" do
    response_set = start_survey('Everything')
    click_button "Special"

    check "No other heating source"
    expect(checkbox("heat2", "neg_1").disabled?).to be_true
    expect(checkbox("heat2", "neg_2").disabled?).to be_true

    uncheck "No other heating source"
    expect(checkbox("heat2", "neg_1").disabled?).to be_false

    check "Electric"
    expect(checkbox("heat2", "neg_1").disabled?).to be_false

    check "Refused"
    expect(checkbox("heat2", "1").disabled?).to be_true
    expect(checkbox("heat2", "neg_2").disabled?).to be_true
  end
end

