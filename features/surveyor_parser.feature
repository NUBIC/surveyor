Feature: Survey creation
  As a 
  I want to write out the survey in the DSL
  So that I can give it to survey participants

  Scenario: Basic questions
    Given I parse
    """
      survey "Simple survey" do
        section "Basic questions" do
          label "These questions are examples of the basic supported input types"

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
    Then there should be 1 survey with:
      | title         |
      | Simple survey |
    And there should be 3 questions with:
      | reference_identifier | text                                                            | pick | display_type |
      | nil                  | These questions are examples of the basic supported input types | none | label        |
      | 1                    | What is your favorite color?                                    | one  | default      |
      | 2b                   | Choose the colors you don't like                                | any  | default      |
    And there should be 8 answers with:
      | reference_identifier | text   | response_class |
      | nil                  | red    | answer         |
      | nil                  | blue   | answer         |
      | nil                  | green  | answer         |
      | nil                  | Other  | answer         |
      | 1                    | orange | answer         |
      | 2                    | purple | answer         |
      | 3                    | brown  | answer         |
      | nil                  | Omit   | answer         |

  Scenario: More complex questions
    Given I parse
    """
      survey "Complex survey" do
        section "Complicated questions" do
          grid "Tell us how you feel today" do
            a "-2"
            a "-1"
            a "0"
            a "1"
            a "2"
            q "down|up" , :pick => :one
            q "sad|happy", :pick => :one
            q "limp|perky", :pick => :one
          end

          q "Choose your favorite utensils and enter frequency of use (daily, weekly, monthly, etc...)", :pick => :any
          a "spoon", :string
          a "fork", :string
          a "knife", :string
          a :other, :string

          repeater "Tell us about the cars you own" do
            q "Make", :pick => :one, :display_type => :dropdown
            a "Toyota"
            a "Ford"
            a "GMChevy"
            a "Ferrari"
            a "Tesla"
            a "Honda"
            a "Other weak brand"
            q "Model"
            a :string
            q "Year"
            a :string
          end
        end
      end  
    """
    Then there should be 1 survey with:
      | title          |
      | Complex survey |
    And there should be 2 question groups with:
      | text                           | display_type |
      | Tell us how you feel today     | grid         |
      | Tell us about the cars you own | repeater     |
    And there should be 7 questions with:
      | text    | pick | display_type |
      | Make    | one  | dropdown     |
    And there should be 28 answers with:
      | text  | response_class |
      | -2    | answer         |
      | Other | string         |

  Scenario: Dependencies and validations
    Given I parse
    """
      survey "Dependency and validation survey" do
        section "Conditionals" do
          q_montypython3 "What... is your name? (e.g. It is 'Arthur', King of the Britons)"
          a_1 :string
    
          q_montypython4 "What... is your quest? (e.g. To seek the Holy Grail)"
          a_1 :string
          dependency :rule => "A"
          condition_A :q_montypython3, "==", {:string_value => "It is 'Arthur', King of the Britons", :answer_reference => "1"}
    
          q "How many pets do you own?"
          a :integer
          validation :rule => "A"
          condition_A ">=", :integer_value => 0
    
          q "What is your address?", :custom_class => 'address'
          a :text, :custom_class => 'mapper'
          validation :rule => "AC"
          vcondition_AC "=~", :regexp => /[0-9a-zA-z\. #]/

          q_2 "Which colors do you loathe?", :pick => :any
          a_1 "red"
          a_2 "blue"
          a_3 "green"
          a_4 "yellow"

          q_2a "Please explain why you hate so many colors?"
          a_1 "explanation", :text
          dependency :rule => "Z"
          condition_Z :q_2, "count>2"
        end
      end
    """
    Then there should be 1 survey with:
      | title                            |
      | Dependency and validation survey |
    And there should be 6 questions with:
      | text                                                             | pick | display_type | custom_class |
      | What... is your name? (e.g. It is 'Arthur', King of the Britons) | none | default      | nil          |
      | What is your address?                                            | none | default      | address      |
    And there should be 2 dependency with:
      | rule |
      | A    |
      | Z    |
    And there should be 2 resolved dependency_condition with:
      | rule_key |
      | A        |
      | Z        |
    And there should be 2 validations with:
      | rule |
      | A    |
      | AC   |
    And there should be 2 validation_conditions with:
      | rule_key | integer_value |
      | A        | 0             |
