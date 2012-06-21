# Surveys On Rails

Surveyor is a developer tool that brings surveys into Rails
applications. Surveys are written in the Surveyor DSL (Domain Specific
Language). Internally, Surveyor is a Rails engine distributed as a
ruby gem, meaning it is straightforward to override or extend its
behaviors in your Rails app without maintaining a fork.

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

Add surveyor to your Gemfile:

    gem "surveyor"

Then run:

    bundle install

Generate assets, run migrations:

    script/rails generate surveyor:install
    rake db:migrate

Try out the "kitchen sink" survey. The rake task above generates surveys from our custom survey DSL (a good format for end users and stakeholders).

    rake surveyor FILE=surveys/kitchen_sink_survey.rb

Start up your app and visit http://localhost:3000/surveys

Try taking the survey and compare it to the contents of the DSL file kitchen\_sink\_survey.rb. See how the DSL maps to what you see.

There are two other useful rake tasks:

* `surveyor:remove` removes all unused surveys.
* `rake surveyor:unparse` exports a survey from the application into a
  file in the surveyor DSL.

# Customizing surveyor

Surveyor's controller, models, and views may be customized via classes in your app/models, app/helpers and app/controllers directories. To generate a sample custom controller and layout, run:

    script/rails generate surveyor:custom

and read surveys/EXTENDING\_SURVEYOR

# The asset pipeline

Surveyor is now aware of the Rails asset pipeline (http://http://guides.rubyonrails.org/asset_pipeline.html). With the asset pipeline enabled (Rails.application.config.assets.enabled == true), then the surveyor:install generator will generate app/assets/stylesheets/surveyor\_all.css and app/assets/javascripts/surveyor\_all.js manifest files and link them from the surveyor\_default layout. Assets remain in the gem and are picked up for inclusion and pre-compilation from there. The previous copy-to-application behavior still exists in the case where the asset pipeline is missing or disabled.

# PDF support

* Add the following lines to your Gemfile:

<pre>
	gem 'pdfkit'
	gem 'wkhtmltopdf'
</pre>

or on OSX:

<pre>
	gem 'pdfkit'
	gem 'wkhtmltopdf-binary'
</pre>

* Add the following to your application.rb:

<pre>
	config.middleware.use PDFKit::Middleware
</pre>

* Create links with :format => 'pdf' in them, for example:

<pre>
	%li= link_to "PDF", view_my_survey_path(:survey_code => response_set.survey.access_code, :response_set_code => response_set.access_code, :format => 'pdf')
</pre>

# Requirements

Surveyor works with:

* Ruby 1.8.7, 1.9.2, and 1.9.3
* Rails 3.0-3.2

Some key library dependencies are:

* HAML
* Sass
* Formtastic

A more exhaustive list can be found in the gemspec.

# Contributing, testing

To work on the code, fork this github project. Install [bundler][] if
you don't have it, then run

    $ bundle update

to install all the necessary gems. Then

    $ bundle exec rake testbed

to generate a test app in `testbed`. Now you can run

    $ bundle exec rake spec

to run the specs and

    $ bundle exec rake cucumber

to run the features and start writing tests!

[bundler]: http://gembundler.com/

Copyright (c) 2008-2011 Brian Chamberlain and Mark Yoon, released under the MIT license
