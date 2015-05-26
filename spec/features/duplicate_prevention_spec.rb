require 'spec_helper'

describe "preventing duplicates", js: true do
  include_context "everything"
  it "saves a simple radio button response" do
    response_set = start_survey('Everything')
    expect(page).to have_content("What is your favorite color?")
    within question("1") do
      choose "blue"
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
      check "orange"
      uncheck "orange"
      check "brown"
    end
    wait_for_ajax
    expect(response_set.count).to eq(2)
    expect(response_set.for("2b", "1").count).to eq(0)
    expect(response_set.for("2b", "2").count).to eq(1)
    expect(response_set.for("2b", "3").count).to eq(1)
  end
  it "saves a string response" do
    response_set = start_survey('Everything')
    expect(page).to have_content("What is the best color for a fire engine?")
    within question("fire_engine") do
      fill_in "Color", with: "yellow"
    end
    within question("2b") do
      check "purple"
    end
    within question("fire_engine") do
      fill_in "Color", with: "red"
    end
    within question("2b") do
      uncheck "purple"
    end
    wait_for_ajax
    expect(response_set.count).to eq(1)
    expect(response_set.for("fire_engine", "color").first.string_value).to eq("red")
  end
end