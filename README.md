# Survey On Rails

Surveyor is a rails (gem) plugin, that brings surveys to your rails app. Before Rails 2.3, it was implemented as a Rails Engine.

Surveys are written in a DSL (Domain Specific Language), with examples available in the "kitchen sink" survey.

# Installation

    script/plugin install git://github.com/breakpointer/surveyor.git

Generate assets, migrations, and run migrations
    
    script/generate surveyor
    rake db:migrate

Try out the "kitchen sink" survey:

    rake surveyor:bootstrap FILE=surveys/kitchen_sink_survey.rb

# Configuration and customization

The surveyor generator creates config/initializers/config.rb. There, you can specify:

- your own custom title for the survey list page
- your own custom layout file
- your own custom finish url for all surveys

The initializer runs once, when the app starts. The block style is used to keep multiple options DRY:

    Surveyor::Config.run do |config|
      config['default.title'] = "You can take these surveys:"
      config['default.layout'] = "surveyor_default"
      config['default.finish'] = Proc.new{ "/surveys" }
    end
    
You can update surveyor's at any time. Use the block style (above), or the individual style:

    Surveyor::Config['default.title'] = "Cheese is great!"

To look at the current surveyor configuration:
    
    Surveyor::Config.to_hash.inspect

# Dependencices

Surveyor depends on the SASS style sheet language, part of HAML (http://haml.hamptoncatlin.com/download)

Copyright (c) 2008-2009 Brian Chamberlain and Mark Yoon, released under the MIT license
