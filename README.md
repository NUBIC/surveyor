# Surveys On Rails

Surveyor is a ruby gem and developer tool that brings surveys into Rails applications. Surveys are written in the Surveyor DSL (Domain Specific Language). Before Rails 2.3, it was implemented as a Rails Engine. It also existed previously as a plugin. Today it is a gem only.

## Why you might want to use Surveyor

If your Rails app needs to asks users questions as part of a survey, quiz, or questionnaire then you should consider using Surveyor. This gem was designed to deliver clinical research surveys to large populations, but it can be used for any type of survey.

The Surveyor DSL defines questions, answers, question groups, survey sections, dependencies (e.g. if response to question 4 is A, then show question 5), and validations. Answers are the options available for each question - user input is called "responses" and are grouped into "response sets". A DSL makes it significantly easier to import long surveys (no more click/copy/paste). It also enables non-programmers to write out, edit, re-edit... any number of surveys.

## DSL example

The Surveyor DSL supports a wide range of question types (too many to list here) and complex dependency logic. Here are the first few questions of the "kitchen sink" survey which should give you and idea of how it works. The full example with all the types of questions available if you follow the installation instructions below.

    survey "Kitchen Sink survey" do
    
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
    
        # ... other question, sections and such. See surveys/kitchen_sink_survey.rb for more.
     end 
    
    end
   
The first question is "pick one" (radio buttons) with "other". The second question is "pick any" (checkboxes) with the option to "omit". It also features a dependency with a follow up question. Notice the dependency rule is defined as a string. We support complex dependency such as "A and (B or C) and D" or "A or ((B and C) or D)". The conditions are evaluated separately using the operators "==","!=","<>", ">=","<" the substituted by letter into to the dependency rule and evaluated.

# Installation

1. Add it to your bundler Gemfile:

gem "surveyor"

`bundle install`

2. Generate assets, run migrations:
    
`script/generate surveyor`
`rake db:migrate`

3. Try out the "kitchen sink" survey. The rake task above generates surveys from our custom survey DSL (a good format for end users and stakeholders).

`rake surveyor FILE=surveys/kitchen_sink_survey.rb`

4. Start up your app and visit:

http://localhost:3000/surveys

Try taking the survey and compare it to the contents of the DSL file kitchen\_sink\_survey.rb. See how the DSL maps to what you see.

There are two other useful rake tasks for removing (only surveys without responses) and un-parsing (from db to DSL file) surveys:

`rake surveyor:remove`
`rake surveyor:unparse`

# Customizing surveyor

Surveyor's controller, models, and views may be customized via classes in your app/models, app/helpers and app/controllers directories. To generate a sample custom controller and layout, run:

`script/generate extend_surveyor`

and read surveys/EXTENDING\_SURVEYOR

# Requirements

Surveyor depends on Ruby (1.8.7 - 1.9.1), Rails 2.3 and HAML/SASS http://haml.hamptoncatlin.com/. It also depends on fastercsv for csv exports.

# Contributing, testing

To work on the code fork this github project. Run:

`rake -f init_testbed.rakefile`

which will generate a test app in testbed. Run rake spec and rake cucumber there, and start writing tests!

Copyright (c) 2008-2010 Brian Chamberlain and Mark Yoon, released under the MIT license
