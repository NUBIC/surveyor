Feature: Survey creation
  As a survey participant
  I want to take a survey
  So that I can get paid

  Scenario: Basic questions
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
    And I choose "red"
    And I choose "blue"
    And I check "orange"
    And I check "brown"
    And I press "Click here to finish"
    Then there should be 1 response set with 3 responses with:
      | to_s   |
      | blue   |
      | orange |
      | brown  |
      
  Scenario: Default answers
    Given the survey
    """
      survey "Favorites" do
        section "Foods" do
          question_1 "What is your favorite food?"
          answer :string, :default_value => "beef"
        end
      end
    """
    When I start the "Favorites" survey
    And I press "Click here to finish"
    Then there should be 1 response set with 1 responses with:
      | to_s   |
      | clear   |
