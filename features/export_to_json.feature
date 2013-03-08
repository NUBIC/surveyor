Feature: Survey export
  As an api consumer
  I want to represent a survey in JSON
  So that I can use it offline

  Scenario: Exporting basic questions
    Given I parse
    """
      survey "Simple json" do
        section "Basic questions" do
          label "These questions are examples of the basic supported input types"

          question_1 "What is your favorite color?", :pick => :one
          answer "red"
          answer "blue"
          answer "green"
          answer :other

          q_2b "Choose the colors you don't like", :pick => :any
          a "orange"
          a "purple"
          a "brown"
          a :omit
        end
      end
    """
    And I visit "/surveys/simple-json.json"
    Then the JSON should be:
    """
    {
      "title": "Simple json",
      "uuid": "*",
      "sections": [{
        "title": "Basic questions",
        "display_order":0,
        "questions_and_groups": [
          { "uuid": "*", "type": "label", "text": "These questions are examples of the basic supported input types" },
          { "uuid": "*", "reference_identifier": "1", "pick": "one", "text": "What is your favorite color?", "answers": [{"text": "red", "uuid": "*"}, {"text": "blue", "uuid": "*"}, {"text": "green", "uuid": "*"}, {"text": "Other", "uuid": "*"}]},
          { "uuid": "*", "reference_identifier": "2b", "pick": "any", "text": "Choose the colors you don't like", "answers": [{"text": "orange", "uuid": "*"},{"text": "purple", "uuid": "*"},{"text": "brown", "uuid": "*"},{"text": "Omit", "exclusive":true, "uuid": "*"}]}]
        }]
      }
    """

  Scenario: Exporting export and reference identifiers
    Given I parse
    """
      survey "Exportable" do
        section "First section" do
          question_1 "What is your favorite color?", :pick => :one, :data_export_identifier => "favorite_color"
          a_red "red"
          a_blue "blue"

          q_2b "Choose the colors you don't like", :pick => :any
          a_1 "orange", :data_export_identifier => "dont_like_orange"
          a_2 "purple"
        end
      end
    """
    And I visit "/surveys/exportable.json"
    Then the JSON should be:
    """
    {
      "title": "Exportable",
      "uuid": "*",
      "sections": [{
        "title": "First section",
        "display_order":0,
        "questions_and_groups": [
          { "uuid": "*", "reference_identifier": "1", "pick": "one", "text": "What is your favorite color?", "data_export_identifier": "favorite_color", "answers": [{"text": "red", "uuid": "*", "reference_identifier": "red"}, {"text": "blue", "uuid": "*", "reference_identifier": "blue"}]},
          { "uuid": "*", "reference_identifier": "2b", "pick": "any", "text": "Choose the colors you don't like", "answers": [{"text": "orange", "uuid": "*", "reference_identifier": "1", "data_export_identifier": "dont_like_orange"},{"text": "purple", "uuid": "*", "reference_identifier": "2"}]}]
        }]
      }
    """

  Scenario: Exporting versioned survey questions
  Given I parse
  """
    survey "Simple json" do
      section "Basic questions" do
        label "These questions are examples of the basic supported input types"

        question_1 "What is your favorite color?", :pick => :one
        answer "red"
        answer "blue"
        answer "green"
        answer :other

        q_2b "Choose the colors you don't like", :pick => :any
        a "orange"
        a "purple"
        a "brown"
        a :omit
      end
    end
  """
  And I parse
  """
    survey "Simple json" do
      section "Not so basic questions" do
        label "These questions are examples of the basic supported input types"

        question_1 "What is your favorite color?", :pick => :one
        answer "reddish"
        answer "blueish"
        answer "greenish"
        answer :other

        q_2b "Choose the colors you don't like", :pick => :any
        a "orange"
        a "purple"
        a "brown"
        a :omit
      end
    end
  """
  And I visit "/surveys/simple-json.json"
  Then the JSON should be:
  """
  {
    "title": "Simple json",
    "uuid": "*",
    "sections": [{
      "title": "Not so basic questions",
      "display_order":0,
      "questions_and_groups": [
        { "uuid": "*", "type": "label", "text": "These questions are examples of the basic supported input types" },
        { "uuid": "*", "reference_identifier": "1", "pick": "one", "text": "What is your favorite color?", "answers": [{"text": "reddish", "uuid": "*"}, {"text": "blueish", "uuid": "*"}, {"text": "greenish", "uuid": "*"}, {"text": "Other", "uuid": "*"}]},
        { "uuid": "*", "reference_identifier": "2b", "pick": "any", "text": "Choose the colors you don't like", "answers": [{"text": "orange", "uuid": "*"},{"text": "purple", "uuid": "*"},{"text": "brown", "uuid": "*"},{"text": "Omit", "exclusive":true, "uuid": "*"}]}]
      }]
    }
  """
  And I visit "/surveys/simple-json.json?survey_version=0"
  Then the JSON should be:
  """
  {
    "title": "Simple json",
    "uuid": "*",
    "sections": [{
      "title": "Basic questions",
      "display_order":0,
      "questions_and_groups": [
        { "uuid": "*", "type": "label", "text": "These questions are examples of the basic supported input types" },
        { "uuid": "*", "reference_identifier": "1", "pick": "one", "text": "What is your favorite color?", "answers": [{"text": "red", "uuid": "*"}, {"text": "blue", "uuid": "*"}, {"text": "green", "uuid": "*"}, {"text": "Other", "uuid": "*"}]},
        { "uuid": "*", "reference_identifier": "2b", "pick": "any", "text": "Choose the colors you don't like", "answers": [{"text": "orange", "uuid": "*"},{"text": "purple", "uuid": "*"},{"text": "brown", "uuid": "*"},{"text": "Omit", "exclusive":true, "uuid": "*"}]}]
      }]
    }
  """

  Scenario: Exporting input mask and mask placeholder
  Given I parse
  """
    survey "Personal" do
      section "Guy" do
        q "What is your phone number?"
        a :string, :input_mask => '(999)999-9999', :input_mask_placeholder => '#'
      end
    end
  """
  And I visit "/surveys/personal.json"
  Then the JSON should be:
    """
    {
      "title": "Personal",
      "uuid": "*",
      "sections": [{
        "display_order": 0,
        "title": "Guy",
        "questions_and_groups": [
          { 
            "uuid": "*", 
            "text": "What is your phone number?",
            "answers": [
              {
                "input_mask": "(999)999-9999",
                "input_mask_placeholder": "#",
                "text": "String",
                "type": "string", 
                "uuid": "*"
              }
            ]
          }]
        }]
      }
    """

  Scenario: Exporting response sets
  Given I parse
  """
    survey "Simple json response sets" do
      section "Section 1" do

        question_1 "What is your favorite color?", :pick => :one
        answer "red"
        answer "blue"
        answer "green"
        answer :other

        q_2b "What color don't you like?"
        a_1 "color", :string
      end
      section "Section 2" do
        label "no"
      end
    end
  """
  When I start the "Simple json response sets" survey
  And I choose "red"
  And I press "Section 2"
  And I press "Section 1"
  And I fill in "color" with "orange"
  And I press "Section 2"
  And I press "Click here to finish"
  Then there should be 1 response set with 2 responses with:
    | answer |
    | red    |
  And I export the response set
  Then the JSON at "responses" should have 2 entries
  Then the JSON should not have "responses/0/value"
  And the JSON response at "responses/0/answer_id" should correspond to an answer with text "red"
  And the JSON response at "responses/1/value" should be "orange"
  And the JSON response at "responses/1/answer_id" should correspond to an answer with text "color"

  # Issue #294 - ResponseSet#to_json generates unexpected results with zero Responses
  Scenario: Exporting response sets without responses
  Given I parse
  """
    survey "Simple json response sets" do
      section "Colors" do

        question_1 "What is your favorite color?", :pick => :one
        answer "red"
        answer "blue"
        answer "green"
        answer :other

        q_2b "What color don't you like?"
        a_1 "color", :string
      end
      section "Other" do
        label "no"
      end
    end
  """
  When I start the "Simple json response sets" survey
  And I export the response set
  Then the JSON at "responses" should be an array
  Then the JSON at "responses" should have 0 entries

  Scenario: Exporting response sets for versioned surveys
  Given I parse
  """
    survey "Simple json response sets" do
      section "Colors" do
        question "What is your least favorite color?"
        a "least favorite color", :string
      end
    end
  """
  And I start the "Simple json response sets" survey
  And I fill in "color" with "orange"
  And I press "Click here to finish"
  And I export the response set
  Then the JSON at "responses" should have 1 entry
  And the JSON response at "responses/0/value" should be "orange"
  And the JSON response at "responses/0/answer_id" should correspond to an answer with text "least favorite color"
  And I parse
  """
    survey "Simple json response sets" do
      section "Colors" do
        question_1 "What is your most favorite color?"
        a "most favorite color", :string
      end
    end
  """
  And I start the "Simple json response sets" survey
  And I fill in "color" with "blueish"
  And I press "Click here to finish"
  And I export the response set
  Then the JSON at "responses" should have 1 entry
  And the JSON response at "responses/0/value" should be "blueish"
  And the JSON response at "responses/0/answer_id" should correspond to an answer with text "most favorite color"

  Scenario: Exporting null datetime response
  Given I parse
  """
    survey "Health" do
      section "Doctor" do
        question "When did you visit?", :pick => :one
        a "Date", :date
        a "Not sure"
      end
    end
  """
  And I start the "Health" survey
  And I choose "Date"
  And I press "Click here to finish"
  And I export the response set
  Then the JSON at "responses" should have 1 entry
  And the JSON response at "responses/0/value" should be null

  Scenario: Exporting non-existent surveys
    When I visit "/surveys/simple-json.json"
    Then I should get a "404" response

  Scenario: Exporting with survey modifications
  Given I parse
  """
    survey "Simple" do
      section "Colors" do
        question "What is your least favorite color?"
        a "least favorite color", :string
      end
    end
  """
  When I prefix the titles of exported surveys with "NUBIC - "
  Then the JSON representation for "Simple" should be:
  """
  {
    "title": "NUBIC - Simple",
    "uuid": "*",
    "sections": [{
      "title": "Colors",
      "display_order":0,
      "questions_and_groups": [
        { "uuid": "*", "text": "What is your least favorite color?", "answers": [{"text": "least favorite color", "uuid": "*", "type": "string"}]}
      ]
    }]
  }
  """
  When I visit "/surveys/simple.json"
  Then the JSON should be:
  """
  {
    "title": "NUBIC - Simple",
    "uuid": "*",
    "sections": [{
      "title": "Colors",
      "display_order":0,
      "questions_and_groups": [
        { "uuid": "*", "text": "What is your least favorite color?", "answers": [{"text": "least favorite color", "uuid": "*", "type": "string"}]}
      ]
    }]
  }
  """
