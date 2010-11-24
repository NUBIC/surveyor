Feature: Survey creation
  As a 
  I want to write out the survey in the DSL
  So that I can give it to survey participants

  Scenario: Basic questions
    Given I parse redcap file "REDCapDemoDatabase_DataDictionary.csv"
    Then there should be 1 survey with:
      ||
    And there should be 143 questions with:
      ||
    And there should be 161 answers with:
      ||
    # And there should be 1 dependency with:
    #   | rule |
    #   | A    |
    # And there should be 1 resolved dependency_condition with:
    #   | rule_key |
    #   | A        |
    # And there should be 2 validations with:
    #   | rule |
    #   | A    |
    #   | AC   |
    # And there should be 2 validation_conditions with:
    #   | rule_key | integer_value |
    #   | A        | 0             |
