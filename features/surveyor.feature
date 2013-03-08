Feature: Survey creation
  As a survey participant
  I want to take a survey
  So that I can get paid

  Scenario: Creating basic questions
    Given I parse
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

  Scenario: Creating default answers
    Given I parse
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

  @quiz
  Scenario: Creating, it's quiz time
    Given I parse
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

  Scenario: Creating custom css class
    Given I parse
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

  Scenario: Creating a pick one question with an option for other
    Given I parse
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

  Scenario: Creating a repeater with a dropdown
    Given I parse
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
  Scenario: Creating a group with a dropdown
    Given I parse
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

  Scenario: Creating another pick one question with an option for other
    Given I parse
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

  Scenario: Creating checkboxes with text area
    Given I parse
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

  Scenario: Creating double letter rule keys
    Given I parse
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

  Scenario: Creating and changing dropdowns
    Given I parse
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
  Scenario: Creating a question with an option checkbox for other and text input
    Given I parse
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
    And I change "r_4_string_value" to "thai"
    Then the "other" checkbox should be checked

  # Issue 234 - empty text field with checkbox
  @javascript
  Scenario: Creating a question with an option checkbox for other and an empty text input
    Given I parse
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
    And I change "r_4_string_value" to ""
    Then the "other" checkbox should not be checked

  # Issue 234 - text field with radio buttons
  @javascript
   Scenario: Creating a question with an option radio button for other and text input
    Given I parse
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
    And I change "r_1_string_value" to "thai"
    Then the "other" radiobutton should be checked

  # Issue 234 - empty text field with radio buttons
  @javascript
  Scenario: Creating another question with an option radio button for other and text input
    Given I parse
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
    And I change "r_1_string_value" to ""
    Then the "other" radiobutton should not be checked


  # Issue 259 - substitution of the text with Mustache
  @javascript @mustache
  Scenario: Creating a question with an mustache syntax
    Given I have survey context of "FakeMustacheContext"
    Given I parse
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
    Then I should see "Information on Santa Claus"
    And I should see "Answer all you know on Santa Claus"
    And I should see "Santa Claus does not work for Northwestern!"
    And I should see "Make sure you sure Santa Claus doesn't work for Northwestern"
    And I should see "Where does Santa Claus live?"
    And I should see "If you don't know where Santa Claus lives, skip the question"
    And I should see "Santa Claus lives on North Pole"
    And I should see "Santa Claus lives on South Pole"
    And I should see "Santa Claus doesn't exist"

  # Issue 296 - Mustache rendering doesn't work with simple hash contexts
  @javascript @mustache
  Scenario: Creating a question with an mustache syntax
    Given I have a simple hash context
    Given I parse
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
    Then I should see "Information on Moses"
    And I should see "Answer all you know on Moses"
    And I should see "Moses does not work for Northwestern!"
    And I should see "Make sure you sure Moses doesn't work for Northwestern"
    And I should see "Where does Moses live?"
    And I should see "If you don't know where Moses lives, skip the question"
    And I should see "Moses lives on North Pole"
    And I should see "Moses lives on South Pole"
    And I should see "Moses doesn't exist"

  Scenario: Creating and saving grids
    Given I parse
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

  Scenario: Creating dates
    Given I parse
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
  Scenario: Creating a date using the JS datepicker
    Given I parse
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
     And I select "May" as the datepicker's month
     And I select "2013" as the datepicker's year
     And I follow "18"
     And I press "Click here to finish"
    Then there should be a date response with value "2013-05-18"

  Scenario: Creating images
    Given I parse
    """
      survey "Images" do
        section "One" do
          q "Which way?"
          a "/images/surveyor/next.gif", :display_type => "image"
          a "/images/surveyor/prev.gif", :display_type => "image"
        end
      end
    """
      And I set the asset directory
    When I start the "Images" survey
    Then I should see the image "/images/surveyor/next.gif"
      And I should see the image "/images/surveyor/prev.gif"

  @javascript
  Scenario: Creating and unchecking checkboxes
    Given I parse
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
    And I start the "Travels" survey
    Then there should be 3 checkboxes
    When I check "Singapore"
    And I press "Activities"
    And I press "Countries"
    Then the "Singapore" checkbox should be checked
    When I uncheck "Singapore"
    And I press "Activities"
    And I press "Countries"
    Then the "Singapore" checkbox should not be checked
    When I check "Singapore"
    Then 1 responses should exist
    When I uncheck "Singapore"
    Then 0 responses should exist

  Scenario: Accessing outdated survey
    Given I parse
    """
      survey "Travels" do
        section "Everything" do
          q "Which of these countries have you visited?", :pick => :any
          a "Italy"
          a "Morocco"
          a "Mexico"
        end
      end
    """
    And I parse
    """
      survey "Travels" do
        section "Countries" do
          q "Which of these countries have you visited?", :pick => :any
          a "Ireland"
          a "Kenya"
          a "Singapore"
        end
      end
    """
    When I go to the surveys page
    And I press "Take it"
    Then I should see "Ireland"
    And I should not see "Italy"

    When I go to the surveys page
    And I select "0" from "survey_version"
    And I press "Take it"
    Then I should see "Mexico"
    And I should not see "Keniya"

  # Issue 236 - ":text"- field doesn't show up in the multi-select questions
  Scenario: Pick one and pick any with text areas
    Given I parse
    """
      survey "Pick plus text" do
        section "Examples" do
          q "What is your best beauty secret?", :pick => :one
          a "My secret is", :text
          a "None of your business"
          a "I don't know"

          q "Who knows about this secret?", :pick => :any
          a "Only you and me, because", :text
          a "These other people:", :text
        end
      end
    """
    When I go to the surveys page
    And I press "Take it"
    Then I should see 3 textareas on the page

  # Issue 207 - Create separate fields for date and time
  Scenario: Pick one and pick any with dates
  Given I parse
  """
    survey "Complex date survey" do
      section "Date questions with pick one and pick any" do
        q "What is your birth date?", :pick => :one
        a "I was born on", :date
        a "Refused"

        q "At what time were you born?", :pick => :any
        a "I was born at", :time
        a "This time is approximate"

        q "When would you like to schedule your next appointment?"
        a :datetime
      end
    end
  """
  When I go to the surveys page
  And I press "Take it"
  Then I should see 1 "date" input on the page
  And I should see 1 "time" input on the page
  And I should see 1 "datetime" input on the page

  # Issue #251 - Dropdowns inside of group display as radio buttons
  Scenario: Dropdown within a group
  Given I parse
  """
    survey "Dropdowns" do
      section "Location" do
        q "What is the address of your new home?", :pick => :one
        a_1 "Address known"
        a_2 "Out of the country"
        a_3 "PO Box address only"
        a_neg_1 "Refused"
        a_neg_2 "Don't know"

        group "Address information" do
          q_NEW_STATE "State", :display_type => :dropdown, :pick=>:one
          a_1 "AL"
          a_2 "AK"
          a_3 "AZ"
          a_4 "AR"
          a_5 "CA"
          a_6 "CO"
        end
      end
    end
  """
  When I go to the surveys page
  And I press "Take it"
  Then I should see 1 select on the page

  # Issue #336 :is_exclusive doesn't disable other answers that are tagged as :is_exclusive
  @javascript
  Scenario: multiple exclusive checkboxes
    Given I parse
    """
      survey "Heat" do
        section "Types" do
          q_heat2 "Are there any other types of heat you use regularly during the heating season
           to heat your home? ", :pick => :any
           a_1 "Electric"
           a_2 "Gas - propane or LP"
           a_3 "Oil"
           a_4 "Wood"
           a_5 "Kerosene or diesel"
           a_6 "Coal or coke"
           a_7 "Solar energy"
           a_8 "Heat pump"
           a_9 "No other heating source", :is_exclusive => true
           a_neg_5 "Other"
           a_neg_1 "Refused", :is_exclusive => true
           a_neg_2 "Don't know", :is_exclusive => true
        end
      end
    """
    When I start the "Heat" survey
     And I click "No other heating source"
    Then the checkbox for "Refused" should be disabled
     And the checkbox for "Don't know" should be disabled
    When I uncheck "No other heating source"
    Then the checkbox for "Refused" should be enabled
    When I check "Electric"
    Then the checkbox for "Refused" should be enabled
    When I check "Refused"
    Then the checkbox for "Electric" should be disabled
     And the checkbox for "Don't know" should be disabled

  # #197 - Add a hidden field type, don't show hidden questions and groups in the DOM
  #        don't use up question numbers on them either. custom class "hidden" doesn't
  #        do anything until you add your own css to hide it
  Scenario: hidden questions for injecting data
    Given I parse
    """
      survey "Sesame Street" do
        section "The Count" do
          q_name "What is your name?", :display_type => :hidden
          a :string, :help_text => "(e.g. Count Von Count)"

          group "Friends", :display_type => :hidden do
            q "Who are your friends?"
            a :string
          end

          label "AH AH AH AH AH!"

          q_numbers "What is your favorite number?", :pick => :one, :custom_class => "hidden"
          a "One"
          a "Two"
          a "Three!"
        end
      end
    """
    When I start the "Sesame Street" survey
    Then I should see "AH AH AH AH AH!"
      And I should see "1) What is your favorite number?"
      And I should not see "What is your name?"

  @numbers
  Scenario: hidden numbers
    Given I parse
    """
      survey "Alpha" do
        section "A-C" do
          q "Aligator"
          q "Barber"
          q "Camel"
        end
      end
    """
      And I replace question numbers with letters
    When I start the "Alpha" survey
    Then I should see "A. Aligator"
      And I should see "B. Barber"
      And I should see "C. Camel"

  Scenario: help text
    Given I parse
    """
      survey "Help!" do
        section "Songs" do
          q "Do you need anybody?", :pick => :one, :help_text => "select one of the following"
          a "I need somebody to love", :help_text => "like The Beatles"
          a "I am a rock, I am an island", :help_text => "like Simon and Garfunkel"

          grid "How would these artists respond to 'Do you need anybody?'", :help_text => "in your opinion" do
            a "Yes", :help_text => "would say yes"
            a "No", :help_text => "would say no"
            q "Bobby Darrin", :pick => :one
            q "Kurt Cobain", :pick => :one
            q "Ella Fitzgerald", :pick => :one
            q "Kanye West", :pick => :one
          end

          repeater "Over and over" do
            q "Row row row your boat", :pick => :any, :help_text => "the 1st part of a round"
            a "gently down the stream", :help_text => "the 2nd part of a round"
            a "merrily merrily merrily merrily", :help_text => "the 3rd part of a round"
            a "life is but a dream", :help_text => "the 4th part of a round"
          end
        end
      end
    """
    When I start the "Help!" survey
    Then I should see "select one of the following"
      And I should see "like The Beatles"
      And I should see "like Simon and Garfunkel"
      And I should see "in your opinion"
      And I should see "would say yes"
      And I should see "would say no"
      And I should see "the 1st part of a round"
      And I should see "the 2nd part of a round"
      And I should see "the 3rd part of a round"
      And I should see "the 4th part of a round"

  Scenario: labels in groups
    Given I parse
    """
      survey "Labels" do
        section "One" do
          group "Grouped" do
            label "Grouped greetings"
            a "Your response", :string
          end
          group "Inline group", :display_type => :inline do
            label "Inline greetings"
            a "Your response", :string
          end
          repeater "Repeater" do
            label "Repeater greetings"
            a "Your response", :string
          end
          grid "Grid" do
            a "Grid response", :string
            label "Grid greetings"
          end
        end
      end
    """
    When I start the "Labels" survey
    Then I should see "Grouped greetings"
      And I should see "Inline greetings"
      And I should see "Repeater greetings"
      And I should see "Grid greetings"
      And I should not see "Your response"
      And I should see "Grid response"
      And I should see no text inputs on the page

  @javascript
  Scenario: dates in pick one
    Given I parse
    """
      survey "Dates" do
        section "One" do
          q_test_1 "When will you stop by?", :pick=>:one
          a_date "On", :date, :custom_class => "date"
          a_neg_1 "REFUSED"
          a_neg_2 "DON'T KNOW"
        end
        section "Two" do
          label "second section"
        end
      end
    """
    When I start the survey
      And I click "On"
      And I click the first date field
      And I select "Mar" as the datepicker's month
      And I select "2013" as the datepicker's year
      And I follow "9"
    Then there should be a date response with value "2013-03-09"
    When I press "Two"
      And I press "One"
    Then the first date field should contain "2013-03-09"
      And the first date field should not contain "2013-03-09 00:00:00.000000"

  @javascript
  Scenario: input mask and input mask placeholder
    Given I parse
    """
      survey "Personal" do
        section "One" do
          q "What is your phone number?"
          a "phone", :string, :input_mask => '(999)999-9999', :input_mask_placeholder => '#'
        end
      end
    """
    When  I start the "Personal" survey
      And I fill in "phone" with "1234567890"
      And I press "Click here to finish"
    Then there should be 1 response set with 1 responses with:
      | string_value  |
      | (123)456-7890 |

    @javascript
    Scenario: numeric input mask with alphanumeric input
    Given I parse
    """
      survey "Personal" do
        section "One" do
          q "What is your phone number?"
          a 'phone', :string, :input_mask => '(999)999-9999'
        end
      end
    """
    When  I start the "Personal" survey
      And I fill in "phone" with "1a2b3c4d5e6f7g8h9i0"
      And I press "Click here to finish"
    Then there should be 1 response set with 1 responses with:
      | string_value  |
      | (123)456-7890 |

    @javascript
    Scenario: alpha input mask with alphanumeric input
    Given I parse
    """
      survey "Personal" do
        section "One" do
          q "What are your favorite letters?"
          a 'letters', :string, :input_mask => 'aaaaaaaaa'
        end
      end
    """
    When  I start the "Personal" survey
      And I fill in "letters" with "1a2b3c4d5e6f7g8h9i0"
      And I press "Click here to finish"
    Then there should be 1 response set with 1 responses with:
      | string_value  |
      | abcdefghi     |