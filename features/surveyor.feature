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
    Then the survey should be complete

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
          q "Anything else to say?", :pick => :any
          a "yes", :string, :custom_class => "other_custom_class"
          q "Random question", :pick => :one
          a "yes", :string, :custom_class => "other_other_custom_class"
        end
      end
    """
    When I start the "Movies" survey
    Then the element "input[type='text'].my_custom_class" should exist
    And the element "input[type='checkbox'].other_custom_class" should exist
    And the element "input[type='radio'].other_other_custom_class" should exist
    And the element "input[type='text'].other_other_custom_class" should exist

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

  Scenario: Repeater with a dropdown
    Given the survey
    """
      survey "Movies" do
        section "Preferences" do
          repeater "What are you favorite genres?" do
            q "Make", :pick => :one, :display_type => :dropdown
            a "Action"
            a "Comedy"
            a "Mystery"
          end
        end
      end
    """
    When I start the "Movies" survey
    Then a dropdown should exist with the options "Action, Comedy, Mystery"

  # Issue 251 - text field with checkbox
  Scenario: Group with a dropdown
    Given the survey
    """
      survey "All Holidays" do
        section "Favorites" do
          group "Holidays" do
            q "What is your favorite holiday?", :pick => :one, :display_type => :dropdown
            a "Christmas"
            a "New Year"
            a "March 8th"
          end
        end
      end
    """
    When I start the "All Holidays" survey
    Then a dropdown should exist with the options "Christmas, New Year, March 8th"

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
    And I fill in "r_1_string_value" with "shrimp"
    And I press "Click here to finish"
    Then there should be 1 response set with 1 response with:
    | shrimp |

  Scenario: Checkboxes with text area
    Given the survey
    """
      survey "Websites" do
        section "Search engines" do
          q "Have you ever used the following services?", :pick => :any
          a "Yellowpages.com|Describe your experience", :text
          a "Google.com|Describe your experience", :text
          a "Bing.com|Describe your experience", :text
        end
      end
    """
    When I start the "Websites" survey
    Then there should be 3 checkboxes
    And there should be 3 text areas

  Scenario: "Double letter rule keys"
    Given the survey
    """
      survey "Doubles" do
        section "Two" do
          q_twin "Are you a twin?", :pick => :one
          a_yes "Oh yes"
          a_no "Oh no"

          q_two_first_names "Do you have two first names?", :pick => :one
          a_yes "Why yes"
          a_no "Why no"

          q "Do you want to be part of an SNL skit?", :pick => :one
          a_yes "Um yes"
          a_no "Um no"
          dependency :rule => "A or AA"
          condition_A :q_twin, "==", :a_yes
          condition_AA :q_two_first_names, "==", :a_yes
        end
        section "Deux" do
          label "Here for the ride"
        end
        section "Three" do
          label "Here for the ride"
        end
      end
    """
    When I start the "Doubles" survey
    Then I choose "Oh yes"
    And I press "Deux"
    And I press "Two"
    Then the question "Do you want to be part of an SNL skit?" should be triggered

  Scenario: "Changing dropdowns"
    Given the survey
    """
      survey "Drop" do
        section "Like it is hot" do
          q "Name", :pick => :one, :display_type => :dropdown
          a "Snoop"
          a "Dogg"
          a "D-O double G"
          a "S-N double O-P, D-O double G"
        end
        section "Two" do
          label "Here for the ride"
        end
        section "Three" do
          label "Here for the ride"
        end
      end
    """
    When I start the "Drop" survey
    Then I select "Snoop" from "Name"
    And I press "Two"
    And I press "Like it is hot"
    And I select "Dogg" from "Name"
    And I press "Two"
    Then there should be 1 response with answer "Dogg"

  # Issue 234 - text field with checkbox
  @javascript
  Scenario: A question with an option checkbox for other and text input
    Given the survey
    """
      survey "Favorite Cuisine" do
        section "Foods" do
          q "What is the best cuisine?", :pick => :any
          a "french"
          a "italian"
          a "chinese"
          a "other", :string
        end
      end
    """
    When I start the "Favorite Cuisine" survey
    And I wait 2 seconds
    And I change "r_4_string_value" to "thai"
    Then the "other" checkbox should be checked

  # Issue 234 - empty text field with checkbox
  @javascript
  Scenario: A question with an option checkbox for other and an empty text input
    Given the survey
    """
      survey "Favorite Cuisine" do
        section "Foods" do
          q "What is the best cuisine?", :pick => :any
          a "french"
          a "italian"
          a "chinese"
          a "other", :string
        end
      end
    """
    When I start the "Favorite Cuisine" survey
    And I wait 2 seconds
    And I change "r_4_string_value" to ""
    Then the "other" checkbox should not be checked

  # Issue 234 - text field with radio buttons
  @javascript
   Scenario: A question with an option radio button for other and text input
    Given the survey
    """
      survey "Favorite Cuisine" do
        section "Foods" do
          q "What is the best cuisine?", :pick => :one
          a "french"
          a "italian"
          a "chinese"
          a "other", :string
        end
      end
    """
    When I start the "Favorite Cuisine" survey
    And I wait 2 seconds
    And I change "r_1_string_value" to "thai"
    Then the "other" radiobutton should be checked

  # Issue 234 - empty text field with radio buttons
  @javascript
  Scenario: A question with an option radio button for other and text input
    Given the survey
    """
      survey "Favorite Cuisine" do
        section "Foods" do
          q "What is the best cuisine?", :pick => :one
          a "french"
          a "italian"
          a "chinese"
          a "other", :string
        end
      end
    """
    When I start the "Favorite Cuisine" survey
    And I wait 2 seconds
    And I change "r_1_string_value" to ""
    Then the "other" radiobutton should not be checked


  # Issue 259 - substitution of the text with Mustache
  @wip
  @javascript
  Scenario: A question with an mustache syntax
    Given I have survey context of "FakeMustacheContext"
    Given the survey
    """
      survey "Overall info" do
        section "Group of questions" do
          group "Information on {{name}}?", :help_text => "Answer all you know on {{name}}" do
            label "{{name}} does not work for {{site}}!", :help_text => "Make sure you sure {{name}} doesn't work for {{site}}"

            q "Where does {{name}} live?", :pick => :one,
            :help_text => "If you don't know where {{name}} lives, skip the question"
            a "{{name}} lives on North Pole"
            a "{{name}} lives on South Pole"
            a "{{name}} doesn't exist"
          end
        end
      end
    """
    When I start the "Overall info" survey
    And I wait 5 seconds
    Then I should see "Information on Santa Claus"
    And I should see "Answer all you know on Santa Claus"
    And I should see "Santa Claus does not work for Northwestern!"
    And I should see "Make sure you sure Santa Claus doesn't work for Northwestern"
    And I should see "Where does Santa Claus live?"
    And I should see "If you don't know where Santa Claus lives, skip the question"
    And I should see "Santa Claus lives on North Pole"
    And I should see "Santa Claus lives on South Pole"
    And I should see "Santa Claus doesn't exist"


  Scenario: "Saving grids"
    Given the survey
    """
      survey "Grid" do
        section "One" do
          grid "Tell us how often do you cover these each day" do
            a "1"
            a "2"
            a "3"
            q "Head", :pick => :one
            q "Knees", :pick => :one
            q "Toes", :pick => :one
          end
        end
        section "Two" do
          label "Here for the ride"
        end
        section "Three" do
          label "Here for the ride"
        end
      end
    """
    When I start the "Grid" survey
    And I choose "1"
    And I press "Two"
    And I press "One"
    Then there should be 1 response with answer "1"

  Scenario: "Dates"
    Given the survey
    """
      survey "When" do
        section "One" do
          q "Tell us when you want to meet"
          a "Give me a date", :date
        end
        section "Two" do
          q "Tell us when you would like to eat"
          a "When eat", :time
        end
        section "Three" do
          q "Tell us when you would like a phone call"
          a "When phone", :datetime
        end
      end
    """
    When I start the "When" survey
    # 2/14/11
    And I fill in "Give me a date" with "2011-02-14"
    # 1:30am
    And I press "Two"
    And I fill in "When eat" with "01:30"
    # 2/15/11 5:30pm
    And I press "Three"
    And I fill in "When phone" with "2011-02-15 17:30:00"

    # Verification
    When I press "One"
    Then the "Give me a date" field should contain "2011-02-14"
    When I press "Two"
    Then the "When eat" field should contain "01:30"
    When I press "Three"
    Then the "When phone" field should contain "2011-02-15 17:30:00"

    # 2/13/11
    When I press "One"
    And I fill in "Give me a date" with "2011-02-13"
    # 1:30pm
    And I press "Two"
    And I fill in "When eat" with "13:30"
    # 2/15/11 5:00pm
    And I press "Three"
    And I fill in "When phone" with "2011-02-15 17:00:00"

    # Verification
    When I press "One"
    Then the "Give me a date" field should contain "2011-02-13"
    When I press "Two"
    Then the "When eat" field should contain "13:30"
    When I press "Three"
    Then the "When phone" field should contain "2011-02-15 17:00:00"

  @javascript
  Scenario: "Date"
    Given the survey
    """
      survey "When" do
        section "One" do
          q "Tell us when you want to meet"
          a "Give me a date", :date
        end
      end
    """
    When I start the "When" survey
    And I click "Give me a date"
    And I follow today's date
    And I press "Click here to finish"
    Then there should be a datetime response with today's date

  Scenario: "Images"
    Given the survey
    """
      survey "Images" do
        section "One" do
          q "Which way?"
          a "/images/surveyor/next.gif", :display_type => "image"
          a "/images/surveyor/prev.gif", :display_type => "image"
        end
      end
    """
    When I start the "Images" survey
    Then I should see the image "/images/surveyor/next.gif"
    And I should see the image "/images/surveyor/prev.gif"

  @javascript
  Scenario: "Unchecking Checkboxes"
    Given the survey
    """
      survey "Travels" do
        section "Countries" do
          q "Which of these countries have you visited?", :pick => :any
          a "Ireland"
          a "Kenya"
          a "Singapore"
        end
        section "Activities" do
          q "What do you like to do on vacation?", :pick => :any
          a "Eat good food"
          a "Lie on the beach"
          a "Wander around cool neighborhoods"
        end
      end
    """
    When I go to the surveys page
    And I wait 1 seconds
    And I start the "Travels" survey
    And I wait 1 seconds
    Then there should be 3 checkboxes
    And I wait 1 seconds
    When I check "Singapore"
    And I wait 1 seconds
    And I press "Activities"
    And I wait 1 seconds
    And I press "Countries"
    And I wait 1 seconds
    Then the "Singapore" checkbox should be checked
    And I wait 1 seconds
    When I uncheck "Singapore"
    And I wait 1 seconds
    And I press "Activities"
    And I wait 1 seconds
    And I press "Countries"
    And I wait 1 seconds
    Then the "Singapore" checkbox should not be checked
    When I check "Singapore"
    And I wait 1 seconds
    Then 1 responses should exist
    When I uncheck "Singapore"
    And I wait 1 seconds
    Then 0 responses should exist
