Feature: Survey with validations
  As a survey participant
  I want to take a survey
  And be notified when I answer incorrectly

  # Issue 34 - client side validation for mandatory question
  @javascript
  Scenario: Creating a mandatory question
    Given I parse
    """
      survey "Mandatory Question" do
        section "Required" do
          q "Type your name. This is required.", :is_mandatory => true
          a "name", :string
        end
      end
    """
    When I start the "Mandatory Question" survey
    And I press "Click here to finish"
    Then I should see "This question is required."


  @javascript
  Scenario: Creating a mandatory pick-one question
    Given I parse
    """
      survey "Mandatory Question" do
        section "Required" do
          q "What do you prefer?", :pick => :one, :is_mandatory => true
          a "enchiladas"
          a "tamales"
          a "tacos"
        end
      end
    """
    When I start the "Mandatory Question" survey
    And I press "Click here to finish"
    Then I should see "This question is required."

  @javascript
  Scenario: Creating a mandatory dropdown question
    Given I parse
    """
      survey "Mandatory Question" do
        section "Required" do
          q "What do you prefer?", :pick => :one, :display_type => :dropdown, :is_mandatory => true
          a "enchiladas"
          a "tamales"
          a "tacos"
        end
      end
    """

    When I start the "Mandatory Question" survey
    And I press "Click here to finish"
    Then I should see "This question is required."

  @javascript
  Scenario: Creating a mandatory pick-any question
    Given I parse
    """
      survey "Mandatory Question" do
        section "Required" do
          q "What do you prefer? select at least one", :pick => :any, :is_mandatory => true

          a "enchiladas"
          a "tamales"
          a "tacos"
        end
      end
    """
    When I start the "Mandatory Question" survey
    And I press "Click here to finish"
    Then I should see "This question is required"

  @javascript
  Scenario: Creating a mandatory pick-any question selecting one
    Given I parse
    """
      survey "Mandatory Question" do
        section "Required" do
          q "What do you prefer? select at least one", :pick => :any, :is_mandatory => true
          a "enchiladas"
          a "tamales"
          a "tacos"
        end
      end
    """
    When I start the "Mandatory Question" survey
    And check "tacos"
    And I press "Click here to finish"
    Then I should not see "This question is required"

  @javascript
  Scenario: Creating a question with an integer answer
    Given I parse
    """
      survey "Integer Question" do
        section "How many" do
          q "How many pets do you own?"
          a "Number", :integer
        end
      end
    """
    When I start the "Integer Question" survey
    And I fill in "Number" with "Eight"
    And I press "Click here to finish"
    Then I should see "Please enter a whole number"

  @javascript
  Scenario: Creating a question with an range rule
    Given I parse
    """
      survey "Integer Question" do
        section "Your age" do
          q "How old are you?"
          a "Age", :integer
          validation :rule => "A and B"
          condition_A ">=", :integer_value => 18
          condition_B "<=", :integer_value => 50
        end
      end
    """
    When I start the "Integer Question" survey
    And I fill in "Age" with "51"
    And I press "Click here to finish"
    Then I should see "Please enter a number between 18 and 50"
    And I fill in "Age" with "17"
    And I press "Click here to finish"
    Then I should see "Please enter a number between 18 and 50"

  @javascript
  Scenario: Creating a question with an float answer
    Given I parse
    """
      survey "Float Question" do
        section "How many" do
          q "How mmuch oil do you use?"
          a "Quantity", :float
        end
      end
    """
    When I start the "Float Question" survey
    And I fill in "Quantity" with "A lot"
    And I press "Click here to finish"
    Then I should see "Please enter a number."

  @javascript
  Scenario: Creating a question with a time answer
    Given I parse
    """
      survey "Time Question" do
        section "When" do
          q "What time is it?"
          a "Time", :time
        end
      end
    """
    When I start the "Time Question" survey
    And I press "When"
    And I fill in "Time" with "0900"
    When I press "Click here to finish"
    Then I should see "Please enter a valid time, between 00:00 and 23:59"

  @javascript
  Scenario: Creating a question with pattern validation
    Given I parse
    """
      survey "String Question" do
        section "Profile" do
          q "What's your email?"
          a "email", :string
          validation :rule => "A"
          condition_A "=~", :regexp => "[-0-9a-zA-Z.+_]+@[-0-9a-zA-Z.+_]+\.[a-zA-Z]{2,4}"
        end
      end
    """
    When I start the "String Question" survey
    And I fill in "email" with "foo@bar"
    When I press "Click here to finish"
    Then I should see "Please use the correct format."

  @javascript @stop
  Scenario: Validate textbox with dependent question
    Given I parse
    """
      survey "String question" do
        section "Profile" do
          q_name "What's your name", :is_mandatory=>true
          a_1 "name", :string

          #dependency check is equality
          q_age "What is your age todd?", :is_mandatory=>true
          a_1 :integer
          dependency :rule => "A"
          condition_A :q_name, "==", {:string_value => "todd", :answer_reference => "1"}
        end
      end
    """
    When I start the "String Question" survey
    And I fill in "name" with "todd"
    When I press "Click here to finish"
    Then I should see "This question is required"

