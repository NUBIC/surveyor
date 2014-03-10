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
    Then I should see "This field is required."

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
    Then I should see "A positive or negative non-decimal number please"

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
    Then I should see "Please enter a valid number."

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
