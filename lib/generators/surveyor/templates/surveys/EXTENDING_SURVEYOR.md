== SurveyorController

The SurveyorController class just includes actions from Surveyor::SurveyorControllerMethods module. You may include your own module, and overwrite the methods or add to them using "super". A template for this customization is in your app/controllers/surveyor\_controller.rb. SurveyorController is "unloadable", so changes in development (and any environment that does not cache classes) will be reflected immediately without restarting the app.

== Models

Surveyor's models can all be customized:

- answer
- dependency_condition
- dependency
- question_group
- question
- response_set
- response
- survey_section
- survey
- validation_condition
- validation

For example, create app/models/survey.rb with the following contents:

    class Survey < ActiveRecord::Base
      include Surveyor::Models::SurveyMethods
      def title
        "Custom #{super}"
      end
    end

== SurveyorHelper

The SurveyorHelper module can be customized just like the models:

    module SurveyorHelper
      include Surveyor::Helpers::SurveyorHelperMethods
      def rc_to_as(type_sym)
        case type_sym.to_s
        when /(integer|float)/ then :string
        when /(datetime)/ then :string
        when /^date$/ then :string
        else type_sym
        end
      end
    end

== Views

Surveyor's views can be overwritten by simply creating views in app/views/surveyor

== Layout

Create a custom SurveyorController as above, and specify your custom layout in it.
