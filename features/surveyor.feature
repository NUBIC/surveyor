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
      
  Scenario: Default answers
    Given the survey
    """
      survey "Favorites" do
        section "Foods" do
          question_1 "What is your favorite food?"
          answer "food", :string, :default_value => "beef"
        end
        section "Section 2" do
        end
        section "Section 3" do
        end
      end
    """
    When I start the "Favorites" survey
    And I press "Section 3"
    And I press "Click here to finish"
    Then there should be 1 response set with 1 responses with:
      | string_value |
      | beef |

    When I start the "Favorites" survey
    And I fill in "food" with "chicken"
    And I press "Foods"
    And I press "Section 3"
    And I press "Click here to finish"
    Then there should be 2 response set with 2 responses with:
      | string_value    |
      | chicken |

  Scenario: Quiz time
    Given the survey
    """
      survey "Favorites" do
        section "Foods" do
          question_1 "What is the best meat?", :pick => :one, :correct => "oink"
          a_oink "bacon"
          a_tweet "chicken"
          a_moo "beef"
        end
      end
    """
    Then question "1" should have correct answer "oink"
    
  Scenario: Custom css class
    Given the survey
    """
      survey "Movies" do
        section "First" do
          q "What is your favorite movie?"
          a :string, :custom_class => "my_custom_class"
          q "What is your favorite state?"
          a :string
        end
      end
    """
    When I start the "Movies" survey
    Then the element "input[type='text']:first" should have the class "my_custom_class"
    # Then the element "input[type='text']:last" should not contain the class attribute
    
  Scenario: A pick one question with an option for other
    Given the survey
    """
      survey "Favorites" do
        section "Foods" do
          q "What is the best meat?", :pick => :one
          a "bacon"
          a "chicken"
          a "beef"
          a "other", :string
        end
      end
    """
    When I start the "Favorites" survey
    Then I choose "bacon"
    And I press "Click here to finish"
    Then there should be 1 response set with 1 response with:
    | bacon |
    
  Scenario: A pick one question with an option for other
    Given the survey
    """
      survey "Favorites" do
        section "Foods" do
          q "What is the best meat?", :pick => :one
          a "bacon"
          a "chicken"
          a "beef"
          a "other", :string
        end
      end
    """
    When I start the "Favorites" survey
    Then I choose "other"
    And I fill in "/.*string_value.*/" with "shrimp"
    And I press "Click here to finish"
    Then there should be 1 response set with 1 responses with:
    | Shrimp |
    
    