Feature: Survey dependencies
  As a survey participant
  I want to see dependent question if conditions are met
  And I do now want to see dependent question if conditions are not met

  @javascript
  Scenario: "Simple question dependencies"
    Given I parse
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
    Then the element "#q_2" should not be hidden
    And the element "#q_3" should be hidden
    When I choose "No"
    Then the element "#q_3" should not be hidden
    And the element "#q_2" should be hidden
    When I press "Second"
    And I press "First"
    Then the element "#q_3" should not be hidden
    And the element "#q_2" should be hidden

  @javascript
  Scenario: "Dependencies inside of the question group"
    Given I parse
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
    Then the element "#q_2" should not be hidden
    And the element "#q_3" should be hidden
    When I choose "No"
    Then the element "#q_3" should not be hidden
    And the element "#q_2" should be hidden
    When I press "Second"
    And I press "First"
    Then the element "#q_3" should not be hidden
    And the element "#q_2" should be hidden


  @javascript
  Scenario: "Dependencies inside of the 'inline' question group"
    Given I parse
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
    Then the element "#q_2" should not be hidden
    And the element "#q_3" should be hidden

    When I choose "No"
    Then the element "#q_3" should not be hidden
    And the element "#q_2" should be hidden

    When I press "Second"
    And I press "First"
    Then the element "#q_3" should not be hidden
    And the element "#q_2" should be hidden

  @javascript
  Scenario: "Dependency on group"
    Given I parse
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
    Then the element "#q_2" should not be hidden
    And the element "#q_3" should not be hidden
    And the element "#q_4" should be hidden

    When I choose "No"
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
    Given I parse
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
    Then the element "#q_2" should not be hidden
    And the element "#q_3" should be hidden
    And the element "#q_4" should be hidden
    And the element "#q_5" should be hidden

    When I choose "Human"
    Then the element "#q_3" should not be hidden
    And the element "#q_4" should be hidden
    And the element "#q_5" should be hidden

    When I choose "Owner Of The World"
    Then the element "#q_3" should be hidden
    And the element "#q_4" should not be hidden
    And the element "#q_5" should be hidden

    When I choose "No"
    Then the element "#q_2" should be hidden
    And the element "#q_3" should be hidden
    And the element "#q_4" should be hidden
    And the element "#q_5" should not be hidden

  #issue #337 answer != condition returns false if question was never activated
  @javascript
  Scenario: Depending with != on questions without responses
    Given I parse
    """
      survey "Cooling" do
        section "Basics" do
          q_cooling_1 "How do you cool your home?", :pick => :one
          a_1 "Fans"
          a_2 "Window AC"
          a_3 "Central AC"
          a_4 "Passive"

          q_cooling_2 "How much does it cost to run your non-passive cooling solutions?"
          dependency :rule => "A"
          condition_A :q_cooling_1, "!=", :a_4
          a_1 "$", :float
        end
      end
    """
    When I go to the surveys page
    And I start the "Cooling" survey
    Then the question "How much does it cost to run your non-passive cooling solutions?" should be triggered
    And I choose "Passive"
    Then the question "How much does it cost to run your non-passive cooling solutions?" should be hidden

  #issue #337 answer != condition returns false if question was never activated
  @javascript
  Scenario: Depending with != on questions without responses
    Given I parse
    """
      survey "Heating" do
        section "Basics" do
          q_heating_1 "How do you heat your home?", :pick => :one
          a_1 "Force air"
          a_2 "Radiators"
          a_3 "Oven"
          a_4 "Passive"

          q_heating_2 "How much does it cost to run your non-passive heating solutions?"
          dependency :rule => "A and B"
          condition_A :q_heating_1, "!=", :a_4
          condition_B :q_heating_1, "count>0"
          a_1 "$", :float
        end
      end
    """
    When I go to the surveys page
    And I start the "Heating" survey
    Then the question "How much does it cost to run your non-passive heating solutions?" should be hidden
    And I choose "Oven"
    Then the question "How much does it cost to run your non-passive heating solutions?" should be triggered

  @javascript
  Scenario: Count== dependencies
    Given I parse
    """
      survey "Counting" do
        section "First" do
          q_counts "How many times do you count a day", :pick => :any
          a_1 "Once for me"
          a_2 "Once for you"
          a_3 "Once for everyone"

          label "Good!"
          dependency :rule => "A"
          condition_A :q_counts, "count==1"

          label "Twice as good!"
          dependency :rule => "A"
          condition_A :q_counts, "count==2"
        end
      end
    """
    When I go to the surveys page
    And I start the "Counting" survey
    Then I should see "How many times do you count a day"
      And the element "#q_2" should be hidden
      And the element "#q_3" should be hidden
    When I check "Once for me"
    Then the element "#q_2" should not be hidden
      And the element "#q_3" should be hidden
    When I check "Once for you"
    Then the element "#q_3" should not be hidden
      And the element "#q_2" should be hidden

  @javascript
  Scenario: Dependency evaluation when the last response is removed
    Given I parse
      """
      survey "Heating" do
        section "Basics" do
          q_heating_1 "How do you heat your home?", :pick => :any
          a_1 "Forced air"
          a_2 "Radiators"
          a_3 "Oven"
          a_4 "Passive"

          q_heating_2 "How much does it cost to run your non-passive heating solutions?"
          dependency :rule => "A"
          condition_A :q_heating_1, "==", :a_1
          a_1 "$", :float
        end
      end
      """
    When I go to the surveys page
      And I start the "Heating" survey
    Then the question "How much does it cost to run your non-passive heating solutions?" should be hidden
      And I check "Forced air"
    Then the question "How much does it cost to run your non-passive heating solutions?" should be triggered
      And I uncheck "Forced air"
    Then the question "How much does it cost to run your non-passive heating solutions?" should be hidden

  @javascript
  Scenario: Dependency evaluation within groups
    Given I parse
      """
      survey "Body" do
        section "Joints" do
          group "Muscle" do
            q_muscles_joints_bones "Muscles, Joints, Bones", :pick => :any, :data_export_identifier => "muscles_joints_bones"
            a_1 "Weakness"
            a_2 "Arthritis"
            a_3 "Cane/Walker"
            a_4 "Morning stiffness"
            a_5 "Joint pain"
            a_6 "Muscle tenderness"
            a_7 :other

            q_muscles_joints_bones_other "Explain", :data_export_identifier => "muscles_joints_bones_other"
            dependency :rule => "A"
            condition_A :q_muscles_joints_bones, "==", :a_7
            a "Explain", :string
          end
        end
      end
      """
    When I go to the surveys page
      And I start the "Body" survey
    Then the question "Explain" should be hidden
    When I check "Other"
    Then the question "Explain" should be triggered
    When I uncheck "Other"
    Then the question "Explain" should be hidden

  @javascript
  Scenario: Dependencies on multi-select (from the kitchen sink)
    Given I parse
    """
    survey "Colors" do
      section "Dependencies" do
        question "What is your favorite color?", :pick => :one
        answer "red is my fav"
        answer "blue is my fav"
        answer "green is my fav"
        answer "yellow is my fav"
        answer :other

        q_2 "Choose the colors you don't like", :pick => :any
        a_1 "red"
        a_2 "blue"
        a_3 "green"
        a_4 "yellow"
        a :omit

        q_2a "Please explain why you don't like this color?"
        a_1 "explanation", :text, :help_text => "Please give an explanation for each color you don't like"
        dependency :rule => "A or B or C or D"
        condition_A :q_2, "==", :a_1
        condition_B :q_2, "==", :a_2
        condition_C :q_2, "==", :a_3
        condition_D :q_2, "==", :a_4

        q_2b "Please explain why you dislike so many colors?"
        a_1 "explanation", :text
        dependency :rule => "Z"
        condition_Z :q_2, "count>2"
      end
    end
    """
    When I go to the surveys page
      And I start the "Colors" survey
      And I choose "red is my fav"
    Then the question "Please explain why you don't like this color?" should be hidden
      And the question "Please explain why you dislike so many colors?" should be hidden
    When I check "red"
    Then the question "Please explain why you don't like this color?" should be triggered
      And the question "Please explain why you dislike so many colors?" should be hidden
    When I check "blue"
      And I check "green"
    Then the question "Please explain why you don't like this color?" should be triggered
      And the question "Please explain why you dislike so many colors?" should be triggered
    When I uncheck "red"
      And I uncheck "blue"
      And I uncheck "green"
    Then the question "Please explain why you don't like this color?" should be hidden
      And the question "Please explain why you dislike so many colors?" should be hidden

