Feature: Survey creation
  As a 
  I want to write out the survey in the DSL
  So that I can give it to survey participants

  Scenario: Basic questions
    Given I parse
    """
      survey "Simple survey" do
        section "Basic questions" do
          label "These questions are examples of the basic supported input types"

          question_1 "What is your favorite color?", :pick => :one
          answer "red"
          answer "blue"
          answer "green"
          answer "yellow"
          answer :other

          q_2b "Choose the colors you don't like", :pick => :any
          a_1 "red"
          a_2 "blue"
          a_3 "green"
          a_4 "yellow"
          a :omit
        end
      end
    """
    Then there should be 1 survey with:
      | title         |
      | Simple survey |
    And there should be 3 questions with:
      | text                                                            | pick |
      | These questions are examples of the basic supported input types | none |
      | What is your favorite color?                                    | one  |
      | Choose the colors you don't like                                | any  |
      # | reference_identifier | text                                                            | pick | display_type |
      # | nil                  | These questions are examples of the basic supported input types | none | label        |
      # | 1                    | What is your favorite color?                                    | one  | default      |
      # | 2b                   | Choose the colors you don't like                                | any  | default      |
    # And there should be 5 answers with:
      