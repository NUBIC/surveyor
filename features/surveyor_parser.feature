Feature: Survey parser
  As a developer
  I want to write out the survey in the DSL
  So that I can give it to survey participants

  Scenario: Parsing basic questions
    Given I parse
    """
      survey "Simple survey" do
        section_basic "Basic questions" do
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
        section_second "Second section" do
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
      | title           | display_order | reference_identifier |
      | Basic questions | 0             | basic                |
      | Second section  | 1             | second               |
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
          grid_feel "Tell us how you feel today" do
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

          repeater_cars "Tell us about the cars you own" do
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
      | text                           | display_type | reference_identifier |
      | Tell us how you feel today     | grid         | feel                 |
      | Tell us about the cars you own | repeater     | cars                 |
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

  @quiz
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
    Then the question "the_answer" should have correct answer "adams"

  @quiz
  Scenario: Parsing a quiz for #365
  Given I parse
  """
    survey "Arithmetic" do
      section "Addtion" do
        q_1 "What is one plus one?", :pick => :one, :correct => "2"
        a_1 "1"
        a_2 "2"
        a_3 "3"
        a_4 "4"

        q_2 "What is five plus one?", :pick => :one, :correct => "6"
        a_5 "five"
        a_6 "six"
        a_7 "seven"
        a_8 "eight"
      end
    end
  """
  Then the question "1" should have correct answer "2"
  Then the question "2" should have correct answer "6"

  Scenario: Parsing typos in blocks
    Given the survey
    """
      survey "Basics" do
        sectionals "Typo" do
        end
      end

    """
    Then the parser should fail with "\"sectionals\" is not a surveyor method."

  Scenario: Parsing bad references
    Given the survey
    """
      survey "Refs" do
        section "Bad" do
          q_watch "Do you watch football?", :pick => :one
          a_1 "Yes"
          a_2 "No"

          q "Do you like the replacement refs?", :pick => :one
          dependency :rule => "A or B"
          condition_A :q_1, "==", :a_1
          condition_B :q_watch, "==", :b_1
          a "Yes"
          a "No"
        end
      end

    """
    Then the parser should fail with "Bad references: q_1; q_1, a_1; q_watch, a_b_1"

  Scenario: Parsing repeated references
    Given the survey
    """
      survey "Refs" do
        section "Bad" do
          q_watch "Do you watch football?", :pick => :one
          a_1 "Yes"
          a_1 "No"

          q_watch "Do you watch baseball?", :pick => :one
          a_yes "Yes"
          a_no  "No"

          q "Do you like the replacement refs?", :pick => :one
          dependency :rule => "A or B"
          condition_A :q_watch, "==", :a_1
          a "Yes"
          a "No"
        end
      end
    """
    Then the parser should fail with "Duplicate references: q_watch, a_1; q_watch"

  Scenario: Parsing with Rails validation errors
    Given the survey
    """
      survey do
        section "Usage" do
          q_PLACED_BAG_1 "Is the bag placed?", :pick => :one
          a_1 "Yes"
          a_2 "No"
          a_3 "Refused"
        end
      end
    """
    Then the parser should fail with "Survey not saved: Title can't be blank"

  Scenario: Parsing bad shortcuts
    Given the survey
    """
      survey "shortcuts" do
        section "Bad" do
          quack "Do you like ducks?", :pick => :one
          a_1 "Yes"
          a_1 "No"
        end
      end
    """
    Then the parser should fail with "\"quack\" is not a surveyor method."

  Scenario: Clearing grid answers
    Given I parse
    """
      survey "Grids" do
        section "Leaking" do
          grid "How would you rate the following?" do
            a "bad"
            a "neutral"
            a "good"
            q "steak" , :pick => :one
            q "chicken", :pick => :one
            q "fish", :pick => :one
          end
          grid "How do you feel about the following?" do
            a "sad"
            a "indifferent"
            a "happy"
            q "births" , :pick => :one
            q "weddings", :pick => :one
            q "funerals", :pick => :one
          end
        end
      end
    """
    Then there should be 18 answers with:
      | text        | display_order |
      | bad         | 0             |
      | neutral     | 1             |
      | good        | 2             |
      | sad         | 0             |
      | indifferent | 1             |
      | happy       | 2             |

  Scenario: Parsing mandatory questions
    Given I parse
    """
      survey "Chores", :default_mandatory => true do
        section "Morning" do
          q "Did you take out the trash", :pick => :one
          a "Yes"
          a "No"

          q "Did you do the laundry", :pick => :one
          a "Yes"
          a "No"

          q "Optional comments", :is_mandatory => false
          a :string
        end
      end
    """
    And there should be 3 questions with:
      | text                       | is_mandatory |
      | Did you take out the trash | true         |
      | Did you do the laundry     | true         |
      | Optional comments          | false        |

  @javascript
  Scenario: Parsing dependencies with "question_" and "answer_" syntax
    Given I parse
    """
      survey "Days" do
        section "Fridays" do
          q_is_it_friday "Is it Friday?", :pick => :one
          a_yes "Yes"
          a_no  "No"

          label "woot!"
          dependency :rule => "A"
          condition_A :question_is_it_friday, "==", :answer_yes
        end
      end
    """
    Then there should be 1 dependency with:
      | rule |
      | A    |
    And there should be 1 resolved dependency_condition with:
      | rule_key |
      | A        |
    When I go to the surveys page
    And I start the "Days" survey
    Then the question "woot!" should be hidden
    And I choose "Yes"
    Then the question "woot!" should be triggered

