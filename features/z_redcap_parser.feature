# The redcap parser feature should run last. If it runs in between other features that use the surveyor parser,
# it causes the DependencyCondition before_save :resolve_references hook to stop running, causing hard to trace failures.
Feature: Survey import from REDCap
  As a developer
  I want to write out the survey in the DSL
  So that I can give it to survey participants

  Scenario: Basic questions from REDCap
    Given I parse redcap file "REDCapDemoDatabase_DataDictionary.csv"
    Then there should be 1 survey with:
      ||
    And there should be 143 questions with:
      ||
    And there should be 233 answers with:
      ||
    And there should be 3 resolved dependency_conditions with:
      | rule_key	| operator	| question_reference | answer_reference |
      | A	 		| ==		| sex				 | 0	  			|
      | A	 		| ==		| sex				 | 0	  			|
      | B	 		| ==		| given_birth		 | 1	  			|	
    And there should be 2 dependencies with:
      | rule    |
      | A       |
      | A and B |
  Scenario: Question level dependencies from REDCap
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
  Scenario: with different headers from REDCap
    Given I parse redcap file "redcap_new_headers.csv"
    Then there should be 1 survey with:
      ||
    And there should be 1 questions with:
      ||
    And there should be 2 answers with:
      ||

  Scenario: with different whitespace from REDCap
    Given I parse redcap file "redcap_whitespace.csv"
    Then there should be 1 survey with:
      ||
    And there should be 2 questions with:
      ||
    And there should be 7 answers with:
      | reference_identifier | text    |
      | 1                    | Lexapro |
      | 2                    | Celexa  |
      | 3                    | Prozac  |
      | 4                    | Paxil   |
      | 5                    | Zoloft  |
      | 0                    | No      |
      | 1                    | Yes     |
