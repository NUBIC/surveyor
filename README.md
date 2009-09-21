# SurveyOnRails

# Install

    script/plugin install git://github.com/breakpointer/surveyor.git

Generate assets, migrations, and run migrations
    
    script/generate surveyor
    rake db:migrate

Try out the "kitchen sink" survey:

    rake surveyor:bootstrap FILE=surveys/kitchen_sink_survey.rb

# Dependencices

Surveyor requires HAML (http://haml.hamptoncatlin.com/download)

Copyright (c) 2008-2009 Brian Chamberlain and Mark Yoon, released under the MIT license
