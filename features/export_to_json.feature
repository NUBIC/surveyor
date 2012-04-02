Feature: Survey export
  As a user
  I want to represent a survey in JSON
  So that I can use it offline

  @wip
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
    Then the json for "Simple json" should be
    """
    {"survey": {
      "title": "Simple json",
      "uuid": "*",
      "sections": [{
        "title": "Basic questions",
        "questions_and_groups": [
          { "uuid": "*", "type": "label", "text": "These questions are examples of the basic supported input types" },
          { "uuid": "*", "reference": "1", "pick": "one", "text": "What is your favorite color?", "answers": [{"text": "red"}, {"text": "blue"}, {"text": "green"}, {"text": "Other"}]},
          { "uuid": "*", "reference": "2b", "pick": "any", "text": "Choose the colors you don't like", "answers": [{"text": "orange"},{"text": "purple"},{"text": "brown"},{"text": "Omit", "exclusive": "true"}]}]
        }]
      }
    }
    """