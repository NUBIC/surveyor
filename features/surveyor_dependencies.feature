Feature: Survey dependencies
  As a survey participant
  I want to see dependent question if conditions are met
  And I do now want to see dependent question if conditions are not met
    
  @javascript
  Scenario: "Simple question dependencies"
    Given the survey
    """
      survey "Anybody" do
        section "First" do
          q_1 "Anybody there?", :pick => :one
          a_1 "Yes"
          a_2 "No"

          q_2 "Who are you??"
          dependency :rule => "A"
          condition_A :q_1, "==", :a_1
          a :string

          q_3 "Weird.. Must be talking to myself..", :pick => :one
          dependency :rule => "A"
          condition_A :q_1, "==", :a_2
          a "Maybe"
          a "Huh?"
        end
        section "Second" do
          q "Anything else?"
          a :string
        end
      end
    """
    When I go to the surveys page
    And I start the "Anybody" survey
    Then I should see "Anybody there?"
    And the element "#q_2" should be hidden
    And the element "#q_3" should be hidden
    When I choose "Yes"
    And I wait 1 seconds
    Then the element "#q_2" should not be hidden
    And the element "#q_3" should be hidden
    When I choose "No"
    And I wait 1 seconds
    Then the element "#q_3" should not be hidden
    And the element "#q_2" should be hidden
    When I press "Second"
    And I press "First"
    Then the element "#q_3" should not be hidden
    And the element "#q_2" should be hidden
  
  @javascript
  Scenario: "Dependencies inside of the question group"
    Given the survey
    """
      survey "Anybody" do
        section "First" do
          group "" do
            q_1 "Anybody there?", :pick => :one
            a_1 "Yes"
            a_2 "No"

            q_2 "Who are you??"
            dependency :rule => "A"
            condition_A :q_1, "==", :a_1
            a :string

            q_3 "Weird.. Must be talking to myself..", :pick => :one
            dependency :rule => "A"
            condition_A :q_1, "==", :a_2
            a "Maybe"
            a "Huh?"
          end    
        end
        section "Second" do
          q "Anything else?"
          a :string
        end
      end
    """
    When I go to the surveys page
    And I start the "Anybody" survey
    Then I should see "Anybody there?"
    And the element "#q_2" should be hidden
    And the element "#q_3" should be hidden
    When I choose "Yes"
    And I wait 1 seconds
    Then the element "#q_2" should not be hidden
    And the element "#q_3" should be hidden
    When I choose "No"
    And I wait 1 seconds
    Then the element "#q_3" should not be hidden
    And the element "#q_2" should be hidden
    When I press "Second"
    And I press "First"
    Then the element "#q_3" should not be hidden
    And the element "#q_2" should be hidden
  
  
  @javascript
  Scenario: "Dependencies inside of the 'inline' question group"
    Given the survey
    """
      survey "Anybody" do
        section "First" do
          group "", :display_type => :inline do
            q_1 "Anybody there?", :pick => :one
            a_1 "Yes"
            a_2 "No"

            q_2 "Who are you??"
            dependency :rule => "A"
            condition_A :q_1, "==", :a_1
            a :string

            q_3 "Weird.. Must be talking to myself..", :pick => :one
            dependency :rule => "A"
            condition_A :q_1, "==", :a_2
            a "Maybe"
            a "Huh?"
          end    
        end
        section "Second" do
          q "Anything else?"
          a :string
        end
      end
    """
    When I go to the surveys page
    And I start the "Anybody" survey
    Then I should see "Anybody there?"
    And the element "#q_2" should be hidden
    And the element "#q_3" should be hidden
    
    When I choose "Yes"
    And I wait 1 seconds
    Then the element "#q_2" should not be hidden
    And the element "#q_3" should be hidden
    
    When I choose "No"
    And I wait 1 seconds
    Then the element "#q_3" should not be hidden
    And the element "#q_2" should be hidden
    
    When I press "Second"
    And I press "First"
    Then the element "#q_3" should not be hidden
    And the element "#q_2" should be hidden

  @javascript
  Scenario: "Dependency on group"
    Given the survey
    """
      survey "Anybody" do
        section "First" do
          q_1 "Anybody there?", :pick => :one
          a_1 "Yes"
          a_2 "No"
          
          group "Who are you?", :display_type => :inline do
            dependency :rule => "A"
            condition_A :q_1, "==", :a_1
            
            q_2 "Name yourself"
            a :string

            q_3 "Why are you here?"
            a :string
          end
          
          group "" do
            dependency :rule => "A"
            condition_A :q_1, "==", :a_2
            
            q_4 "Who is talking?", :pick => :one
            a "You are"
            a "Are you nuts?"
          end
              
        end
        section "Second" do
          q "Anything else?"
          a :string
        end
      end
    """
    When I go to the surveys page
    And I start the "Anybody" survey
    Then I should see "Anybody there?"
    And the element "#q_2" should be hidden
    And the element "#q_3" should be hidden
    And the element "#q_4" should be hidden
    
    When I choose "Yes"
    And I wait 1 seconds
    Then the element "#q_2" should not be hidden
    And the element "#q_3" should not be hidden
    And the element "#q_4" should be hidden
    
    When I choose "No"
    And I wait 1 seconds
    Then the element "#q_2" should be hidden
    And the element "#q_3" should be hidden
    And the element "#q_4" should not be hidden
    
    When I press "Second"
    And I press "First"
    Then the element "#q_2" should be hidden
    And the element "#q_3" should be hidden
    And the element "#q_4" should not be hidden
      
  @javascript
  Scenario: "Dependency on question in dependent group"
    Given the survey
    """
      survey "Anybody" do
        section "First" do
          q_1 "Anybody there?", :pick => :one
          a_1 "Yes"
          a_2 "No"

          group "Who are you?" do
            dependency :rule => "A"
            condition_A :q_1, "==", :a_1

            q_2 "Are you..", :pick => :one
            a_1 "Human"
            a_2 "Dancer"
            a_3 "Owner Of The World"

            q_3 "Why are you here?"
            dependency :rule => "A"
            condition_A :q_2, "==", :a_1
            a :string
            
            q_4 "Which one?"
            dependency :rule => "A"
            condition_A :q_2, "==", :a_3
            a :string
          end

          group "" do
            dependency :rule => "A"
            condition_A :q_1, "==", :a_2

            q_5 "Who is talking?", :pick => :one
            a "You are"
            a "Are you nuts?"
          end

        end
        section "Second" do
          q "Anything else?"
          a :string
        end
      end
    """
    When I go to the surveys page
    And I start the "Anybody" survey
    Then I should see "Anybody there?"
    And the element "#q_2" should be hidden
    And the element "#q_3" should be hidden
    And the element "#q_4" should be hidden
    And the element "#q_5" should be hidden
    
    When I choose "Yes"
    And I wait 1 seconds
    Then the element "#q_2" should not be hidden
    And the element "#q_3" should be hidden
    And the element "#q_4" should be hidden
    And the element "#q_5" should be hidden
    
    When I choose "Human"
    And I wait 1 seconds
    Then the element "#q_3" should not be hidden
    And the element "#q_4" should be hidden
    And the element "#q_5" should be hidden

    When I choose "Owner Of The World"
    And I wait 1 seconds
    Then the element "#q_3" should be hidden
    And the element "#q_4" should not be hidden
    And the element "#q_5" should be hidden
    
    When I choose "No"
    And I wait 1 seconds
    Then the element "#q_2" should be hidden
    And the element "#q_3" should be hidden
    And the element "#q_4" should be hidden
    And the element "#q_5" should not be hidden
