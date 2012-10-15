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
          a_1 "orange"
          a_2 "purple"
          a_3 "brown"
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
        a_1 "orange"
        a_2 "purple"
        a_3 "brown"
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
        a_1 "orange"
        a_2 "purple"
        a_3 "brown"
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