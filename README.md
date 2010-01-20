# Survey On Rails

Surveyor is a rails (gem) plugin, that brings surveys to your rails app. Before Rails 2.3, it was implemented as a Rails Engine. Surveys are written in a DSL (Domain Specific Language), with examples available in the "kitchen sink" survey.

# Installation

As a plugin:

    gem install haml
    script/plugin install git://github.com/breakpointer/surveyor.git -r 'tag v0.9.9'

Or as a gem plugin:
  
    # in environment.rb
    config.gem "surveyor", :version => '>=0.9.9'
  
    rake gems:install

Generate assets, run migrations:
    
    script/generate surveyor
    rake db:migrate

Try out the "kitchen sink" survey:

    rake surveyor FILE=surveys/kitchen_sink_survey.rb

The rake surveyor task overwrites previous surveys by default, but can append instead:

    rake surveyor FILE=surveys/kitchen_sink_survey.rb APPEND=true

The rake tasks above generate surveys in our custom survey DSL (which is a great format for end users and stakeholders to use). 
After you have run them start up your app and goto http://<my_app_root>/surveys (http://localhost:3000/surveys for example). 
Try taking the survey and compare what is in there to the DSL in the file kitchen_sink_survey.rb to see how each type of
DLS defined question maps to one that is in the actual survey web interface.

# Configuration

The surveyor generator creates config/initializers/surveyor.rb. There, you can specify:

- your own relative root for surveys ('/' is not recommended as any path will be interpreted as a survey name)
- your own custom title (string) for the survey list page
- your own custom layout file name, in your app/views/layouts folder
- your own custom finish url for all surveys. you can give a string (a path), a symbol (the name of a method in ApplicationController)
- if you would like surveys to require authorization via the restful_authentication plugin
- if you would like to extend the surveyor_controller (see Extending Surveyor below)

The initializer runs once, when the app starts. The block style is used to keep multiple options DRY (defaults below):

    Surveyor::Config.run do |config|
      config['default.relative_url_root'] = "surveys/" # should end with '/'
      config['default.title'] = "You can take these surveys:"
      config['default.layout'] = "surveyor_default"
      config['default.finish'] =  "/surveys"
      config['use_restful_authentication'] = false
      config['extend_controller'] = false
    end
    
You can update surveyor's at any time. Use the block style (above), or the individual style:

    Surveyor::Config['default.title'] = "Cheese is great!"

To look at the current surveyor configuration:
    
    Surveyor::Config.to_hash.inspect

# Extending surveyor

Surveyor's models, helper, and controller can be extended from custom modules your app/models, app/helpers and app/controllers directories. To generate the sample files and sample layout, run:

    script/generate extend_surveyor

Any of surveyor's models class_eval, class methods, and instance methods can be modified. Include the following in config/initializers/surveyor.rb:

    require 'models/survey_extensions' # Extended the survey model

SurveyorHelper class_eval and instance methods can be modified. Include the following in config/initializers/surveyor.rb:

    require 'helpers/surveyor_helper_extensions' # Extend the surveyor helper

SurveyorController class_eval, class methods, instance methods, and actions can be modified. Action methods should be specified separately in the Actions submodule. Set the following option in config/initializers/surveyor.rb Surveyor::Config block:

    config['extend_controller'] = true

# Sample layout

    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    <head>
      <meta http-equiv="content-type" content="text/html;charset=UTF-8" />
      <title>Survey: <%= controller.action_name %></title>
      <%= surveyor_includes # calls surveyor_javascripts + surveyor_stylesheets %>
    </head>
    <body>
      <div id="flash"><%= flash[:notice] %></div>
      <div id="survey_with_menu">
        <%= yield %>
      </div>
    </body>
    </html>
  
The <code>surveyor\_includes</code> helper just calls <code>surveyor\_stylsheets + surveyor\_javascripts</code> which in turn call:

    stylesheet_link_tag 'surveyor/reset', 'surveyor/surveyor', 'surveyor/ui.theme.css','surveyor/jquery-ui-slider-additions'

    javascript_include_tag 'surveyor/jquery-1.2.6.js', 'surveyor/jquery-ui-personalized-1.5.3.js', 'surveyor/accessibleUISlider.jQuery.js','surveyor/jquery.form.js', 'surveyor/surveyor.js'
    
# Dependencices

Surveyor depends on Rails 2.3 and the SASS style sheet language, part of HAML (http://haml.hamptoncatlin.com/download)

# Changes

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
