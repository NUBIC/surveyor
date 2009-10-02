# Survey On Rails

Surveyor is a rails (gem) plugin, that brings surveys to your rails app. Before Rails 2.3, it was implemented as a Rails Engine. Surveys are written in a DSL (Domain Specific Language), with examples available in the "kitchen sink" survey.

# Installation

As a plugin:

    sudo gem install haml
    script/plugin install git://github.com/breakpointer/surveyor.git

Or as a gem plugin:
  
  # in environment.rb
  config.gem "surveyor", :version => '>=0.4.1', :lib => false
  
    sudo rake gems:install

Generate assets, run migrations
    
    script/generate surveyor
    rake db:migrate

Try out the "kitchen sink" survey:

    rake surveyor:bootstrap FILE=surveys/kitchen_sink_survey.rb

# Configuration and customization

The surveyor generator creates config/initializers/config.rb. There, you can specify:

- your own relative root for surveys ('/' is not recommended as any path will be interpreted as a survey name)
- your own custom title (string) for the survey list page
- your own custom layout file name, in your app/views/layouts folder
- your own custom finish url for all surveys. you can give a string (a path), a symbol (the name of a method in ApplicationController)
- if you would like surveys to require authorization via the restful_authentication plugin

The initializer runs once, when the app starts. The block style is used to keep multiple options DRY (defaults below):

    Surveyor::Config.run do |config|
      config['default.relative_url_root'] = "surveys/" # should end with '/'
      config['default.title'] = "You can take these surveys:"
      config['default.layout'] = "surveyor_default"
      config['default.finish'] =  "/surveys"
      config['use_restful_authentication'] = false
    end
    
You can update surveyor's at any time. Use the block style (above), or the individual style:

    Surveyor::Config['default.title'] = "Cheese is great!"

To look at the current surveyor configuration:
    
    Surveyor::Config.to_hash.inspect


# Sample layout

    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    <head>
      <meta http-equiv="content-type" content="text/html;charset=UTF-8" />
      <title>Survey: <%= controller.action_name %></title>
      <%= surveyor_includes %>
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

Copyright (c) 2008-2009 Brian Chamberlain and Mark Yoon, released under the MIT license
