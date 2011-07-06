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
  Scenario: question level dependencies
    Given I parse redcap file "redcap_siblings.csv"
    Then there should be 1 survey with:
      ||
    And there should be 2 questions with:
      ||
    And there should be 2 answers with:
      ||
    And there should be 1 resolved dependency_conditions with:
      | rule_key |
	  | A    	 |
    And there should be 1 dependencies with:
      | rule    |
      | A       |
  Scenario: with different headers
    Given I parse redcap file "redcap_new_headers.csv"
    Then there should be 1 survey with:
      ||
    And there should be 1 questions with:
      ||
    And there should be 2 answers with:
      ||
