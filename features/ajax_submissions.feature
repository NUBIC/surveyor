@javascript
Feature: AJAX submissions
  As a survey administrator
  I want participants' responses to be saved as soon as possible

Scenario: With a simple pick-one question
  Given the question
    """
    q_1 "Was this saved?", :pick => :one
    a_y "Yes"
    a_n "No"
    """
  When I start the survey
   And I choose "Yes"
  Then there should be a response for answer "y"

Scenario: With a simple pick-any question
  Given the question
    """
    q_1 "What is the state of the cat?", :pick => :any
    a_d "Dead"
    a_a "Alive"
    a_s "Sleeping"
    """
  When I start the survey
   And I check "Alive"
   And I check "Sleeping"
  Then there should be a response for answer "a"
   And there should be a response for answer "s"
   And there should not be a response for answer "d"

Scenario: With a free text question
  Given the question
    """
    q_1 "What is your favorite movie?"
    answer "Title", :string
    """
  When I start the survey
   And I fill in "Title" with "The Shawshank Redemption"
   And I click elsewhere
  Then there should be a string response with value "The Shawshank Redemption"

Scenario: With a date question
  Given the question
    """
    q_1 "When do you want to depart?"
    answer "Departure date", :date
    """
    When I start the survey
     And I click "Departure date"
     And I select "Mar" as the datepicker's month
     And I select "2013" as the datepicker's year
     And I follow "9"
    Then there should be a date response with value "2013-03-09"

Scenario: With a datetime question
  Given the question
    """
    q_1 "When do you want to depart?"
    answer "Departure date and time", :datetime
    """
    When I start the survey
     And I click "Departure date and time"
     And I select "Apr" as the datepicker's month
     And I select "2013" as the datepicker's year
     And I follow "8"
    Then there should be a date response with value "2013-04-08 00:00:00"

# How to move the sliders progammatically?
@wip
Scenario: With a time question
  Given the question
    """
    q_1 "When do you want lunch?"
    answer "Meal time", :time
    """
    When I start the survey
     And I click "Meal time"
     And ?
    Then there should be a time response with value "11:45:00"

Scenario: With a pick-one plus free text question
  Given the question
    """
    q_1 "Where is Panama City?", :pick => :one
    a_florida "Florida"
    a_panama "Panama"
    a_other :other, :string
    """
  When I start the survey
   And I fill in the string for "other" with "Chicago"
  Then I click elsewhere
   And there should be a string response for answer "other" with value "Chicago"

# How to move the slider programmatically?
@wip
Scenario: With a slider
  Given the question
    """
    q_1 "How many?", :pick => :one, :display_type => :slider
    a_0   "None"
    a_10  "Some"
    a_100 "Lots"
    """
  When I start the survey
   And ?
  Then there should be a response for answer "100"

# Issue #339
Scenario: With a grid question
  Given the question
    """
    grid "Tell us how often do you cover these each day" do
      a_1 "1"
      a_2 "2"
      a_3 "3"
      q_h "Head", :pick => :one
      q_k "Knees", :pick => :one
      q_t "Toes", :pick => :one
    end
    """
  When I start the survey
   And I choose "3"
  Then there should be a response for answer "3"

Scenario: With a repeater
  Given the question
    """
    repeater "List your former addresses" do
      q "Address"
      a_address_line "Line", :string
    end
    """
  When I start the survey
   And I fill in the 1st string for "address_line" with "10 Downing St."
   And I press "+ add row"
   And I fill in the 2nd string for "address_line" with "1600 Penn Ave."
   And I click elsewhere
  Then there should be a string response for answer "address_line" with value "10 Downing St."
   And there should be a string response for answer "address_line" with value "1600 Penn Ave."
