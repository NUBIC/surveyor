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
    And there should be 233 answers with:
      ||
    And there should be 3 resolved dependency_conditions with:
      ||
    And there should be 2 dependencies with:
      | rule    |
      | A       |
      | A and B |
