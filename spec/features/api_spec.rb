require 'spec_helper'

describe "surveyor API" do
  context "surveys" do
    include_context "favorites"
    include_context "feelings"
    it "exports simple surveys" do
      visit "/surveys/favorites.json"
      expect(json_response).to be_json_eql(%({
        "title": "Favorites",
        "uuid": "*",
        "sections": [{
          "title": "Colors",
          "reference_identifier": "colors",
          "display_order":0,
          "questions_and_groups": [
            { "uuid": "*", "type": "label", "text": "These questions are examples of the basic supported input types" },
            { "uuid": "*", "reference_identifier": "1", "pick": "one", "text": "What is your favorite color?", "answers": [{"text": "red", "uuid": "*", "reference_identifier": "r", "data_export_identifier": "1"}, {"text": "blue", "uuid": "*", "reference_identifier": "b", "data_export_identifier": "2"}, {"text": "green", "uuid": "*", "reference_identifier": "g", "data_export_identifier": "3"}, {"text": "Other", "uuid": "*"}]},
            { "uuid": "*", "reference_identifier": "2b", "pick": "any", "text": "Choose the colors you don't like", "answers": [{"text": "orange", "uuid": "*", "reference_identifier": "1"},{"text": "purple", "uuid": "*", "reference_identifier": "2"},{"text": "brown", "uuid": "*", "reference_identifier": "3"},{"text": "Omit", "exclusive":true, "uuid": "*"}]},
            { "uuid": "*", "reference_identifier": "fire_engine", "text": "What is the best color for a fire engine?", "answers": [{"reference_identifier": "color","text": "Color","type": "string"}]}
          ]
        },{
          "title": "Numbers",
          "reference_identifier": "numbers",
          "display_order": 1,
          "questions_and_groups": []
        }]
      }))
    end
    it "returns 404 for non-existent surveys" do
      visit "/surveys/not-a-survey.json"
      expect(page.status_code).to eq(404)
    end
    it "allows survey modifications" do
      survey = Survey.where(title: "Favorites").first
      survey.extend title_modification_module("MODIFIED")
      Survey.stub_chain(:where, :order).and_return([survey])
      visit "/surveys/favorites.json"
      expect(json_response).to be_json_eql(%("MODIFIED Favorites")).at_path("title")
    end
    it "exports input mask and mask placeholder" do
      survey_text = %(
        survey "Telephone" do
          section "Cellular" do
            q "What is your cell phone number?"
            a :string, :input_mask => '(999)999-9999', :input_mask_placeholder => '#'
          end
        end
      )
      Surveyor::Parser.parse survey_text
      visit "/surveys/telephone.json"
      expect(json_response).to be_json_eql(%({
        "title": "Telephone",
        "uuid": "*",
        "sections": [{
          "display_order": 0,
          "title": "Cellular",
          "questions_and_groups": [{
            "uuid": "*",
            "text": "What is your cell phone number?",
            "answers": [{
              "input_mask": "(999)999-9999",
              "input_mask_placeholder": "#",
              "text": "String",
              "type": "string",
              "uuid": "*"
            }]
          }]
        }]
      }))
    end
  end
  context "versioned surveys" do
    include_context "favorites"
    include_context "favorites-ish"
    it "exports the current version" do
      visit "/surveys/favorites.json"
      expect(json_response).to be_json_eql(%([
        { "uuid": "*", "type": "label", "text": "These questions are examples of the basic supported input types" },
        { "uuid": "*", "reference_identifier": "1", "pick": "one", "text": "What is your favorite color?", "answers": [{"text": "redish", "uuid": "*", "reference_identifier": "r", "data_export_identifier": "1"}, {"text": "blueish", "uuid": "*", "reference_identifier": "b", "data_export_identifier": "2"}, {"text": "greenish", "uuid": "*", "reference_identifier": "g", "data_export_identifier": "3"}, {"text": "Other", "uuid": "*"}]},
        { "uuid": "*", "reference_identifier": "2b", "pick": "any", "text": "Choose the colors you don't like", "answers": [{"text": "orangeish", "uuid": "*", "reference_identifier": "1"},{"text": "purpleish", "uuid": "*", "reference_identifier": "2"},{"text": "brownish", "uuid": "*", "reference_identifier": "3"},{"text": "Omit", "exclusive":true, "uuid": "*"}]},
        { "uuid": "*", "reference_identifier": "fire_engine", "text": "What is the best color for a fire engine?", "answers": [{"reference_identifier": "color","text": "Color","type": "string"}]}
      ])).at_path("sections/0/questions_and_groups")
    end
    it "exports the previous version" do
      visit "/surveys/favorites.json?survey_version=0"
      expect(json_response).to be_json_eql(%([
        { "uuid": "*", "type": "label", "text": "These questions are examples of the basic supported input types" },
        { "uuid": "*", "reference_identifier": "1", "pick": "one", "text": "What is your favorite color?", "answers": [{"text": "red", "uuid": "*", "reference_identifier": "r", "data_export_identifier": "1"}, {"text": "blue", "uuid": "*", "reference_identifier": "b", "data_export_identifier": "2"}, {"text": "green", "uuid": "*", "reference_identifier": "g", "data_export_identifier": "3"}, {"text": "Other", "uuid": "*"}]},
        { "uuid": "*", "reference_identifier": "2b", "pick": "any", "text": "Choose the colors you don't like", "answers": [{"text": "orange", "uuid": "*", "reference_identifier": "1"},{"text": "purple", "uuid": "*", "reference_identifier": "2"},{"text": "brown", "uuid": "*", "reference_identifier": "3"},{"text": "Omit", "exclusive":true, "uuid": "*"}]},
        { "uuid": "*", "reference_identifier": "fire_engine", "text": "What is the best color for a fire engine?", "answers": [{"reference_identifier": "color","text": "Color","type": "string"}]}
      ])).at_path("sections/0/questions_and_groups")
    end
  end
  context "response sets" do
    include_context "favorites"
    it "exports response sets" do
      response_set = start_survey('Favorites')
      choose "red"
      choose "blue"
      fill_in "Color", with: "red"
      click_button "Next section"
      click_button "Click here to finish"
      visit("/surveys/favorites/#{response_set.access_code}.json")
      expect(json_response).to be_json_eql(%("#{Answer.where(text: "blue").first.api_id}")).at_path("responses/0/answer_id")
      expect(json_response).to be_json_eql(%("red")).at_path("responses/1/value")
      expect(json_response).to be_json_eql(%("#{Answer.where(text: "Color").first.api_id}")).at_path("responses/1/answer_id")
    end
    it "exports null datetime responses" do
      survey_text = %(
        survey "Health" do
          section "Doctor" do
            question "When did you visit?", :pick => :one
            a "Date", :date
            a "Not sure"
          end
        end
      )
      Surveyor::Parser.parse survey_text
      response_set = start_survey('Health')
      choose "Date"
      click_button "Click here to finish"
      visit("/surveys/health/#{response_set.access_code}.json")
      expect(json_response).to be_json_eql(%(null)).at_path("responses/0/value")
    end
    it "exports response sets without responses" do
      # Issue #294 - ResponseSet#to_json generates unexpected results with zero Responses
      response_set = start_survey('Favorites')
      click_button "Next section"
      click_button "Click here to finish"
      visit("/surveys/favorites/#{response_set.access_code}.json")
      expect(json_response).to have_json_size(0).at_path("responses")
    end
  end
  context "versioned survey response sets" do
    include_context "favorites"
    include_context "favorites-ish"
    it "exports response sets of the current version" do
      response_set = start_survey('Favorites')
      choose "redish"
      choose "blueish"
      click_button "Next section"
      click_button "Click here to finish"
      visit("/surveys/favorites/#{response_set.access_code}.json")
      expect(json_response).to be_json_eql(%("#{Answer.where(text: "blueish").first.api_id}")).at_path("responses/0/answer_id")
    end
    it "exports response sets of the previous version" do
      response_set = start_survey('Favorites', version: '0')
      choose "blue"
      choose "red"
      click_button "Next section"
      click_button "Click here to finish"
      visit("/surveys/favorites/#{response_set.access_code}.json")
      expect(json_response).to be_json_eql(%("#{Answer.where(text: "red").first.api_id}")).at_path("responses/0/answer_id")
    end
  end
end