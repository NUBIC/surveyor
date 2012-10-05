Feature: Survey parser
  As a developer
  I want to write out the survey in the DSL
  So that I can give it to survey participants

  Scenario: Parsing basic questions
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
          a_1 "orange", :display_order => 1
          a_2 "purple", :display_order => 2
          a_3 "brown", :display_order => 0
          a :omit
        end
        section "Second section" do
        end
      end
      survey "Second survey" do
      end
    """
    Then there should be 2 surveys with:
      | title         | display_order |
      | Simple survey | 0             |
      | Second survey | 1             |
    And there should be 2 sections with:
      | title           | display_order |
      | Basic questions | 0             |
      | Second section  | 1             |
    And there should be 3 questions with:
      | reference_identifier | text                                                            | pick | display_type | display_order |
      | nil                  | These questions are examples of the basic supported input types | none | label        | 0             |
      | 1                    | What is your favorite color?                                    | one  | default      | 1             |
      | 2b                   | Choose the colors you don't like                                | any  | default      | 2             |
    And there should be 8 answers with:
      | reference_identifier | text   | response_class | display_order |
      | nil                  | red    | answer         | 0             |
      | nil                  | blue   | answer         | 1             |
      | nil                  | green  | answer         | 2             |
      | nil                  | Other  | answer         | 3             |
      | 1                    | orange | answer         | 1             |
      | 2                    | purple | answer         | 2             |
      | 3                    | brown  | answer         | 0             |
      | nil                  | Omit   | answer         | 3             |

  Scenario: Parsing more complex questions
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

  Scenario: Parsing dependencies and validations
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

  Scenario: Parsing other dependencies and validations
    Given I parse
    """
      survey "dependency test" do
        section "section 1" do

          q_copd_sh_1 "Have you ever smoked cigarettes?",:pick=>:one,:help_text=>"NO means less than 20 packs of cigarettes or 12 oz. of tobacco in a lifetime or less than 1 cigarette a day for 1 year."
          a_1 "Yes"
          a_2 "No"

          q_copd_sh_1a "How old were you when you first started smoking cigarettes?", :help_text=>"age in years"
          a :integer
          dependency :rule => "A"
          condition_A :q_copd_sh_1, "==", :a_1

          q_copd_sh_1b "Do you currently smoke cigarettes?",:pick=>:one, :help_text=>"as of 1 month ago"
          a_1 "Yes"
          a_2 "No"
          dependency :rule => "B"
          condition_B :q_copd_sh_1, "==", :a_1

          q_copd_sh_1c "On the average of the entire time you smoked, how many cigarettes did you smoke per day?"
          a :integer
          dependency :rule => "C"
          condition_C :q_copd_sh_1, "==", :a_1

          q_copd_sh_1bb "How many cigarettes do you smoke per day now?"
          a_2 "integer"
          dependency :rule => "D"
          condition_D :q_copd_sh_1b, "==", :a_1


          q_copd_sh_1ba "How old were you when you stopped?"
          a "Years", :integer
          dependency :rule => "E"
          condition_E :q_copd_sh_1b, "==", :a_2

        end
      end
    """
    Then there should be 5 dependencies
    And question "copd_sh_1a" should have a dependency with rule "A"
    And question "copd_sh_1ba" should have a dependency with rule "E"

  Scenario: Parsing dependencies on questions inside of a group
    Given I parse
    """
      survey "Phone Screen Questions" do
        section "Phone Screen" do
          q_diabetes "Diabetes", :pick => :one
          a_yes "Yes"
          a_no "No"

          q_high_blood_preassure "High blood pressure?", :pick => :one
          a_yes "Yes"
          a_no "No"

          group do
            dependency :rule => "A"
            condition_A :q_diabetes, "==", :a_yes
            label "It looks like you are not eligible for this specific study at the time"
          end

          group "Eligible" do
            dependency :rule => "A"
            condition_A :q_diabetes, "==", :a_no

            label "You're Eligible!"

            label "You need medical clearance"
            dependency :rule => "A"
            condition_A :q_high_blood_preassure, "==", :a_yes

            label "You don't need medical clearance"
            dependency :rule => "A"
            condition_A :q_high_blood_preassure, "==", :a_no
          end
        end
      end
    """
    Then there should be 4 dependencies
    And 2 dependencies should depend on questions
    And 2 dependencies should depend on question groups

  Scenario: Parsing dependencies with "a"
    Given I parse
    """
      survey "Dependencies with 'a'" do
        section "First" do
          q_data_collection "Disease data collection", :pick => :one
          a_via_chart_review "Via chart review"
          a_via_patient_interview "Via patient interview/questionnaire"

          q_myocardial_infaction "Myocardinal Infarction", :pick => :one
          dependency :rule => "A"
          condition_A :q_data_collection, "==", :a_via_chart_review
          a_yes "Yes"
          a_no "No"
        end
      end
    """
    And there should be 1 dependency with:
      | rule |
      | A    |
    And there should be 1 resolved dependency_condition with:
      | rule_key |
      | A        |

  Scenario: Parsing dependencies with "q"
    Given I parse
    """
      survey "Dependencies with 'q'" do
        section "First" do
          q_rawq_collection "Your rockin rawq collection", :pick => :one
          a_rawqs "Rawqs"
          a_doesnt_rawq "Doesn't rawq"

          q_do_you_rawq "Do you rawq with your rockin rawq collection?", :pick => :one
          dependency :rule => "A"
          condition_A :q_rawq_collection, "==", :a_rawqs
          a_yes "Yes"
          a_no "No"
        end
      end
    """
    And there should be 1 dependency with:
      | rule |
      | A    |
    And there should be 1 resolved dependency_condition with:
      | rule_key |
      | A        |

  Scenario: Parsing a quiz
    Given I parse
    """
      survey "Quiz time" do
        section "First" do
          q_the_answer "What is the 'Answer to the Ultimate Question of Life, The Universe, and Everything'", :correct => "adams"
          a_pi "3.14"
          a_zero "0"
          a_adams "42"
        end
      end
    """
    Then there should be 1 question with a correct answer

  Scenario: Parsing errors
    Given the survey
    """
      survey "Basics" do
        sectionals "Typo" do
        end
      end

    """
    Then the parser should fail with "Dropping the Sectionals block like it's hot!"