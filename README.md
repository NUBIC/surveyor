## Why surveyor?

Surveyor is a developer tool to deliver surveys in Rails applications.
Surveys are written in the surveyor DSL (Domain Specific
Language). A DSL makes it significantly easier to import long surveys
(one of the motivations for building surveyor was copy/paste fatigue).
It enables non-programmers to write out, edit, and review surveys.

If your Rails app needs to asks users questions as part of a survey, quiz,
or questionnaire then you should consider using surveyor. This gem was
designed to deliver clinical research surveys to large populations,
but it can be used for any type of survey.

Surveyor is a Rails engine distributed as a ruby gem, meaning it is
straightforward to override or extend its behaviors in your Rails app
without maintaining a fork.

## Requirements

Please note: this fork of surveyor works with:

* Ruby 2.0.0 (may work on 1.9 but not tested) 
* Rails 4.0

Some key dependencies are:

* HAML
* Sass
* Formtastic
* Protected Attributes (NB: will be removed in future version)

A more exhaustive list can be found in the [gemspec][].

[gemspec]: https://github.com/NUBIC/surveyor/blob/master/surveyor.gemspec
[policy]: http://weblog.rubyonrails.org/2013/2/24/maintenance-policy-for-ruby-on-rails/

## Install

Add surveyor to your Gemfile:

    gem 'surveyor', :git => 'git://github.com/ferrisoxide/surveyor.git'
    gem 'protected_attributes'
    
Add the following to your application.rb config section

    config.active_record.mass_assignment_sanitizer = :strict
    config.active_record.whitelist_attributes = true
    
Please note, the protected_attributes gem will be removed in a future version. These config settings will also be deprecated in favour of Rails 4's Strong Parameters.
         
Bundle, install, and migrate:

    bundle install
    script/rails generate surveyor:install
    bundle exec rake db:migrate

Parse the "kitchen sink" survey ([kitchen sink](http://en.wiktionary.org/wiki/everything_but_the_kitchen_sink) means almost everything)

    bundle exec rake surveyor FILE=surveys/kitchen_sink_survey.rb

Start up your app, visit `/surveys`, compare what you see to [kitchen\_sink\_survey.rb][kitchensink] and try responding to the survey.

[kitchensink]: http://github.com/NUBIC/surveyor/blob/master/lib/generators/surveyor/templates/surveys/kitchen_sink_survey.rb

## Customize surveyor

Surveyor's controller, helper, models, and views may be overridden by classes in your `app` folder. To generate a sample custom controller and layout run:

    script/rails generate surveyor:custom

and read the instructions generated in [`surveys/EXTENDING_SURVEYOR.MD`][extending]

[extending]: https://github.com/NUBIC/surveyor/blob/master/lib/generators/surveyor/templates/surveys/EXTENDING_SURVEYOR.md

## Upgrade surveyor

To get the latest version of surveyor, bundle, install and migrate:

    bundle update surveyor
    script/rails generate surveyor:install
    bundle exec rake db:migrate

and review the [changelog][] for changes that may affect your customizations.

[changelog]: https://github.com/NUBIC/surveyor/blob/master/CHANGELOG.md

## What surveyor does and doesn't do

### Does do
* use a DSL to parse large surveys without hours of copy/paste into a gui builder
* support complex, rule-based dependencies (skip-logic)
* JSON export of both surveys and response sets
* allow customization of all models, views, and controller, as well as helpers and routes
* follow semantic versioning
* exclusive checkboxes - a checkbox that when checked, unchecks all the others

### Doesn't do
* Enforce mandatory questions... yet (although it does have some[1] methods[2] on ResponseSet to support that)
* Dependencies within repeaters... yet [#235](http://github.com/NUBIC/surveyor/issues/235)
* Validations within the UI... yet [#34](http://github.com/NUBIC/surveyor/issues/34), although it does have model support and database representations
* GUI creating, editing, deleting and administration of surveys... yet [#414](http://github.com/NUBIC/surveyor/issues/414)
* Consistently support HTML tags in title, text, help_text attributes. We intend to move to markdown support [#413](http://github.com/NUBIC/surveyor/issues/413) so that same survey definition can be used with [nu_surveyor](http://github.com/NUBIC/nu_surveyor).

[1]: http://github.com/NUBIC/surveyor/blob/master/lib/surveyor/models/response_set_methods.rb#L94
[2]: http://github.com/NUBIC/surveyor/blob/master/lib/surveyor/models/response_set_methods.rb#L97


## Users of spork

There is [an issue with spork and custom inputs in formatstic (#851)][851]. A workaround (thanks rmm5t!):

    Spork.prefork do
      # ...
      surveyor_path = Gem.loaded_specs['surveyor'].full_gem_path
      Dir["#{surveyor_path}/app/inputs/*_input.rb"].each { |f| require File.basename(f) }
      # ...
    end

[851]: https://github.com/justinfrench/formtastic/issues/851

## Follow master

If you are following pre-release versions of surveyor using a `:git`
source in your Gemfile, be particularly careful about reviewing migrations after
updating surveyor and re-running the generator. We will never change a migration
between two released versions of surveyor. However, we may on rare occasions
change a migration which has been merged into master. When this happens, you'll
need to assess the differences and decide on an appropriate course of action for
your app. If you aren't sure what this means, we do not recommend that you deploy an app
that's locked to surveyor master into production.

## Support

For general discussion (e.g., "how do I do this?"), please send a message to the
[surveyor-dev][] group. This group is moderated to keep out spam; don't be
surprised if your message isn't posted immediately.

For reproducible bugs, please file an issue on the [GitHub issue tracker][issues].
Please include a minimal test case (a detailed description of
how to trigger the bug in a clean rails application). If you aren't sure how to
isolate the bug, send a message to [surveyor-dev][] with what you know and we'll
try to help.

For build status see our [continuous integration page][ci].

Take a look at our [screencast][] (a bit dated now).

[surveyor-dev]: https://groups.google.com/group/surveyor-dev
[issues]: https://github.com/NUBIC/surveyor/issues
[ci]:https://public-ci.nubic.northwestern.edu/job/surveyor/
[screencast]:http://vimeo.com/7051279

## Contribute, test

To work on the code, fork this github project. Install [bundler][] if
you don't have it, then bundle, generate the app in `testbed`, and run the specs and features

    $ export RAILS_VERSION=4.0
    $ bundle update
    $ bundle exec rake testbed
    $ bundle exec rake spec
    $ bundle exec rake cucumber

[bundler]: http://gembundler.com/

## Selenium

Some of surveyor's integration tests use Selenium WebDriver and Capybara. The
WebDriver-based tests default to running in Chrome due to an unfortunate
[Firefox bug][FF566671]. For them to run, you'll either need:

* Chrome and [chromedriver][] installed, or
* to switch to use Firefox instead

To use Firefox instead of Chrome, invoke one or more features with
`SELENIUM_BROWSER` set in the environment:

    $ SELENIUM_BROWSER=firefox bundle exec rake cucumber
    $ SELENIUM_BROWSER=firefox bundle exec cucumber features/ajax_submissions.feature

Note that when running features in Firefox, you must allow the WebDriver-driven
Firefox to retain focus, otherwise some tests will fail.

[FF566671]: https://bugzilla.mozilla.org/show_bug.cgi?id=566671
[chromedriver]: http://code.google.com/p/selenium/wiki/ChromeDriver

Copyright (c) 2008-2013 Brian Chamberlain and Mark Yoon, released under the [MIT license][mit]

[mit]: https://github.com/NUBIC/surveyor/blob/master/MIT-LICENSE
