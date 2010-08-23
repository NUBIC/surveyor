# Survey On Rails

Surveyor is a rails gem that brings surveys to your rails app. It is implemented as a Rails 3 Engine. Surveys are written in a DSL (Domain Specific Language), with examples available in the "kitchen sink" survey.

## Why you might want to use Surveyor

If you want to ask your users questions as part of a survey, quiz, or questionnaire, then you should consider using Surveyor. This plugin was designed out of the need to deliver clinical research surveys to large populations but may be used for any type of survey. It has an easy to use DSL to define the questions, response dependencies (if user answers 'A' to question 1 then show question 1a, etc...), and structure (different sections of longer questionnaires).

To build your questionnaire you define it using a custom DSL. Having a DSL instead of a GUI makes it significantly easier to import long surveys (no more endless clicking and typing into tiny text boxes). It also means that you can let your customer write out the survey, edit, re-edit, tweak, throw out and start over, any number of surveys without having to change a single line of code in your app. 

## DSL example

Our DSL supports a wide range of question types (too many to list here) and varying dependency logic. Here are the first few questions of the "kitchen_sink" survey which should give you and idea of how the DSL works. The full example with all the types of questions is in the plugin and available if you run the installation instructions below.

    survey "&#8220;Kitchen Sink&#8221; survey" do
    
      section "Basic questions" do
        # A label is a question that accepts no answers
        label "These questions are examples of the basic supported input types"
    
        # A basic question with radio buttons
        question_1 "What is your favorite color?", :pick => :one
        answer "red"
        answer "blue"
        answer "green"
        answer "yellow"
        answer :other
    
        # A basic question with checkboxes
        # "question" and "answer" may be abbreviated as "q" and "a"
        q_2 "Choose the colors you don't like", :pick => :any
        a_1 "red"
        a_2 "blue"
        a_3 "green"
        a_4 "yellow"
        a :omit
    
        # A dependent question, with conditions and rule to logically join them  
        # the question's reference identifier is "2a", and the answer's reference_identifier is "1"
        # question reference identifiers used in conditions need to be unique on a survey for the lookups to work
        q_2a "Please explain why you don't like this color?"
        a_1 "explanation", :text
        dependency :rule => "A or B or C or D"
        condition_A :q_2, "==", :a_1
        condition_B :q_2, "==", :a_2
        condition_C :q_2, "==", :a_3
        condition_D :q_2, "==", :a_4
    
        # ... other question, sections and such. See kitchen_sink_survey.rb for more.
     end 
    
    end
   
The survey above shows a couple simple question types. The first one is a "pick one" type with the "other" custom entry. The second question is a "pick any" type with the option to "omit". It also has a dependency where you can ask a follow up question based on how the user answered the previous question. Notice the way the dependency is defined as a string. This implementation supports any number of complex dependency rules so not just "A or B or C or D" but "A and (B or C) and D" or "!A or ((B and !C) or D)". The conditions are the letters used they are evaluated separately using the operators defined for "==","<>", ">=","<", (the usual stuff) the plugged in to the dependency rule and evaluated. See the example survey for more details.

# Installation

As a plugin:

    gem install haml
    gem install fastercsv
    script/plugin install git://github.com/breakpointer/surveyor.git -r 'tag v0.13.0'

Or as a gem:
  
    # in environment.rb
    config.gem "surveyor", :version => '~> 0.13.0', :source => 'http://gemcutter.org'
  
    rake gems:install

Or as a gem (with bundler):

    # in environment.rb
    gem "surveyor", '~> 0.13.0'

    bundle install

Generate assets, run migrations:
    
    script/generate surveyor
    rake db:migrate

Try out the "kitchen sink" survey:

    rake surveyor FILE=surveys/kitchen_sink_survey.rb

The rake surveyor task overwrites previous surveys by default, but can append instead:

    rake surveyor FILE=surveys/kitchen_sink_survey.rb APPEND=true

The rake tasks above generate surveys in our custom survey DSL (which is a great format for end users and stakeholders to use). 
After you have run them start up your app and go to:

    http://localhost:3000/surveys

Try taking the survey and compare it to the contents of the DSL file kitchen\_sink\_survey.rb. See how each type of
DSL question maps to the resulting rendered view of the question.

# Customizing surveyor

Surveyor's controller, models, and views may be customized via classes in your app/models, app/helpers and app/controllers directories. To generate a sample custom controller and layout, run:

    script/rails generate surveyor:custom

and check out surveys/README\_FOR\_CUSTOM\_SURVEYOR.md

# Dependencices

Surveyor depends on Rails 3 and HAML (http://haml.hamptoncatlin.com/download).

# Test and Development

To work on the plugin code clone git://github.com/yoon/base\_app\_for\_surveyor.git and follow the instructions in README.


# Changes

0.12.0

* http://www.themodestrubyist.com/2010/03/01/rails-3-plugins---part-1---the-big-picture/
* http://www.themodestrubyist.com/2010/03/05/rails-3-plugins---part-2---writing-an-engine/
* http://www.themodestrubyist.com/2010/03/16/rails-3-plugins---part-3---rake-tasks-generators-initializers-oh-my/
* http://www.themodestrubyist.com/2010/03/22/rails-3-plugins---part-4---more-on-generators/
* http://rdoc.info/rdoc/wycats/thor/blob/f939a3e8a854616784cac1dcff04ef4f3ee5f7ff/Thor/Actions.html

0.11.0

* basic csv export. closes #21
* add unique indicies. closes #45
* add one_integer renderer. closes #51
* constrain surveys to have unique access_codes. closes #45. closes #42
* covering the extremely unlikely case that response_sets may have a non-unique access_code. closes #46. thanks jakewendt.
* current user id not needed in the view, set in SurveyorController. closes #48. thanks jakewendt

0.10.0

* surveyor config['extend'] is now an array. custom modules (e.g. SurveyExtensions are now included from within surveyor models, allowing 
the customizations to work on every request in development. closes #39. thanks to mgurley and jakewendt for the suggestions.
* remove comment from surveyor_includes
* css tweak
* automatically add backslashes and eliminate multiple backslashes in relative root for routes
* readme spelling and line breaks
* fixing a failing spec with factory instead of mock parent model
* upgrading cucumber to 0.6

0.9.11

* adding rails init.rb to make gem loading work. thanks mike gurley. closes #52.
* Repeater changed to only have +1, not +3 as previous
* added locking and transaction to surveyor update action. Prevents bug that caused duplicated answers
* some light re-factoring and code readability changes
* some code formatting changes
* added require statement to specs so the factory_girl test dependency was more clear
* spiced up the readme... may have some typos
* readme update

0.9.10

* styles, adding labels for dates, correcting labels for radio buttons

0.9.9

* count label and image questions complete when mandatory. closes #38
* validate by other responses. closes #35

0.9.8

* @current\_user.id if @current\_user isn't nil. Closes #37

0.9.7

* fixing typos
* remove surveyor controller from load\_once\_paths. fixes issue with dependencies and unloading in development. closes #36

0.9.6

* response set reports progress and mandatory questions completeness. closes #33
* adding correctness to response sets
* adding correctness to responses

0.9.5

* allow append for survey parser. closes #32

0.9.4

* making tinycode compatible with ruby 1.8.6

0.9.3

* fix for survey parser require

0.9.2

* fixing specs for namespacing and move of tinycode
* namespacing SurveyParser models to avoid conflict with model extensions

0.9.1

* fix for tinycode, more descriptive missing method

0.9.0

* validations in dsl and surveyor models
* preserve underscores in reference identifiers
* dsl specs, refactoring into base class
* adding display order to surveys
* moving columnizer and tiny column functionality to surveyor module
* columnizer (and tiny code) refactoring, columnizer spec extracted from answer spec
* cleanup of scopes with joins
* refactoring dependency

0.8.0

* question group dependencies
* expanded examples in kitchen sink survey
* specs

0.7.1

* custom index page
* custom classes and renderers
* fixing typo in kitchen sink survey

0.7.0

* new kitchen sink survey with better documentation of DSL
* migration misspelling
* fixing ordering, dependency conditions evaluation, and changing named scopes for now
* DRYing up surveyor DSL models
* working on adding dependencies for question groups


Copyright (c) 2008-2009 Brian Chamberlain and Mark Yoon, released under the MIT license
