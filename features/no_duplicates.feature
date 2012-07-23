@javascript @slow_updates @simultaneous_ajax
Feature: Duplicate response prevention
  As a survey administrator
  I want to get exactly the number of responses entered
  So that my results are analytically valid

Scenario: With a simple pick-one question
  Given the question
    """
    q_1 "Was this saved?", :pick => :one
    a_y "Yes"
    a_n "No"
    """
  When I start the survey
   And I choose "Yes"
   And I choose "No"
   And I wait for things to settle out
  Then there should be a response for answer "n"
   And there should not be a response for answer "y"

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
   And I check "Dead"
   And I uncheck "Dead"
   And I check "Sleeping"
   And I wait for things to settle out
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
   And I fill in "Title" with "Rear Window"
   And I click elsewhere
   And I wait for things to settle out
   And there should be a string response with value "Rear Window"
  Then there should not be a string response with value "The Shawshank Redemption"

Scenario: With a pick-one plus free text question
  Given the question
    """
    q_1 "Where is Panama City?", :pick => :one
    a_florida "Florida"
    a_panama "Panama"
    a_other :other, :string
    """
  When I start the survey
   And I choose "Florida"
   And I choose "Other"
   And I fill in the string for "other" with "Chicago"
   And I click elsewhere
   And I wait for things to settle out
  Then there should be a string response for answer "other" with value "Chicago"
   And there should not be a response for answer "florida"

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
   And I choose row 1, column 3 of the grid
   And I choose row 1, column 2 of the grid
   And I choose row 2, column 1 of the grid
   And I wait for things to settle out
  Then there should be a response for answer "2" on question "h"
   And there should not be a response for answer "3" on question "h"
   And there should be a response for answer "1" on question "k"

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
   And I fill in the 2nd string for "address_line" with "1600 Pennsylvania Ave."
   And I click elsewhere
   And I wait for things to settle out longer
  Then there should be a string response for answer "address_line" with value "10 Downing St."
   And there should not be a string response for answer "address_line" with value "1600 Penn Ave."
   And there should be a string response for answer "address_line" with value "1600 Pennsylvania Ave."
