Feature: Survey creation
  As a survey participant
  I want to take a survey
  So that I can get paid

  Scenario: Basic questions
    Given the survey
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
    And I choose "red"
    And I choose "blue"
    And I check "orange"
    And I check "brown"
    And I press "Click here to finish"
    Then there should be 1 response set with 3 responses with:
      | to_s   |
      | blue   |
      | orange |
      | brown  |
      
  Scenario: Default answers
    Given the survey
    """
      survey "Favorites" do
        section "Foods" do
          question_1 "What is your favorite food?"
          answer :string, :default_value => "beef"
        end
      end
    """
<<<<<<< HEAD
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
  Scenario: Group dependencies
    Given I parse
    """
      survey "Group dependencies" do
        section "Meds" do
          repeater "Medication regimen (PPI)" do
            dependency :rule => "A"
            condition_A :q_dayone_1, "==", :a_2
              q_dayone_2 "Medication", :pick=> :one, :display_type => :dropdown
                a_0 "None"
                a_1 "Dexlansoprazole (Kapidex)"
                a_2 "Esomeprazole (Nexium)"
                a_3 "Lansoprazole (Prevacid)"
                a_4 "Omeprazole (Prilosec)"
                a_5 "Omeprazole, Sodium Bicarbonate (Zegerid)"
                a_6 "Pantoprazole (Protonix)"
                a_7 "Rabeprazole (Aciphex)"
                a_8 "Other", :string

              q_dayone_3 "Dose (mg)"
                a :string
              q_dayone_4 "Frequency", :pick => :one, :display_type => :dropdown
                a_1 "Daily (AM)"
                a_2  "Daily (PM)"
                a_3 "Twice daily"
          end
        end
      end
    """
    And there should be 1 group dependency with:
      | rule |
      | A    |
      
    
=======
    When I start the "Favorites" survey
    And I press "Click here to finish"
    Then there should be 1 response set with 1 responses with:
      | to_s   |
      | clear   |
>>>>>>> formtastic
