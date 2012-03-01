Feature: showing a survey
  As a survey administrator
  I want to see a survey that a participant has taken
  So that I can understand the data

  Scenario: Take a survey, then look at it
    Given the survey
    """
      survey "Favorites" do
        section "Colors" do
          label "You with the sad eyes don't be discouraged"

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
    When I start the "Favorites" survey
    Then I should see "You with the sad eyes don't be discouraged"
    And I choose "red"
    And I choose "blue"
    And I check "orange"
    And I check "brown"
    And I press "Click here to finish"
    Then there should be 1 response set with 3 responses with:
      | answer |
      | blue   |
      | orange |
      | brown  |
    When I go to the last response set show page
    Then the "blue" radiobutton should be checked
    And the "orange" checkbox should be checked
    And the "brown" checkbox should be checked
