# SurveyOnRails

# Install

Create a rails app:

    rails your_survey_app
    cd your_survey_app
    mv public/index.html public/index.html.old

Install the HAML gem:

    sudo gem install --no-ri --no-rdoc haml

Install the surveyor plugin:
    
    script/plugin install git://github.com/breakpointer/surveyor.git
    or... 
    git submodule add git://github.com/breakpointer/surveyor.git vendor/plugins/surveyor; git submodule init; git submodule update

Run the migrations:

    rake db:migrate

# Dependencices

Surveyor requires HAML (http://haml.hamptoncatlin.com/download)

Copyright (c) 2008-2009 Brian Chamberlain and Mark Yoon, released under the MIT license
