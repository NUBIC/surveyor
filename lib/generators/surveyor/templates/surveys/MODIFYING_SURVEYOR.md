== Dates, Times, and Javascript Date Picker

== Default JQuery Date Picker

By default Surveyor uses the JQuery-UI date picker (http://jqueryui.com/demos/datepicker/)
for all date and time fields (denoted by :date, :time, or :datetime for the answer in the survey).

== Using Rails Date Helpers

It is possible (and relatively easy) to use the default Rails
date helpers (http://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html)
instead of the javascript date picker.

To do so you would need to override two methods in the SurveyorHelperMethods. Currently the
rc_to_attr and rc_to_as handle how the form fields are displayed. The formtastic input method
(https://github.com/justinfrench/formtastic) used in the _answer.html.haml partial
calls the rc_to_attr method to get the attribute for the answer object
and then calls the rc_to_as method to get the value to set the :as parameter.

    ff.input rc_to_attr(a.response_class), :as => rc_to_as(a.response_class)

    def rc_to_attr(type_sym)
      case type_sym.to_s
      when /^answer$/ then :answer_id
      else "#{type_sym.to_s}_value".to_sym
      end
    end

    def rc_to_as(type_sym)
      case type_sym.to_s
      when /(integer|float|date|time|datetime)/ then :string
      else type_sym
      end
    end

First, we would need to set that the attribute to be used is the :datetime_value attribute on the
answer. (By default we use the custom date_value and time_value methods which wrap the :datetime_value
on the answer to work with the string representation of those values). To do this we would need to
change the rc_to_attr method so that either the date or time types return the :datetime_value attribute

    def rc_to_attr(type_sym)
      case type_sym.to_s
      when /^date|time$/ then :datetime_value
      when /^(string|text|integer|float|datetime)$/ then "#{type_sym.to_s}_value".to_sym
      else :answer_id
      end
    end


Second, we would need to update the rc_to_as method so that the date, time, and/or datetime
answer types would return those values rather than string as they do by default

    def rc_to_as(type_sym)
      case type_sym.to_s
      when /(integer|float)/ then :string
      else type_sym
      end
    end

Of course, you could mix and match which attribute types could be show with the Rails Date Helper
methods and which ones could use the javascript date picker.

== JQuery Tools Date Input

If you would like to use JQuery Tools dateinput instead (http://jquerytools.org/demos/dateinput/index.html)
you would need to edit the
vendor/assets/javascripts/surveyor/jquery.surveyor.js file.

Replace the jquery-ui datepicker lines:

    jQuery("input[type='text'].date").datepicker({
    	dateFormat: 'yy-mm-dd',
    	changeMonth: true,
    	changeYear: true
    });

with those for the jquery tools dateinput

    jQuery('li input.date').dateinput({
        format: 'dd mmm yyyy'
    });

(note that you may need to add the following to make the jquery tools dateinput widget to work properly)

    jQuery('li.date input').change(function(){
        if ( $(this).data('dateinput') ) {
            var date_obj = $(this).data('dateinput').getValue();
            this.value = date_obj.getFullYear() + "-" + (date_obj.getMonth()+1) + "-" +
                date_obj.getDate() + " 00:00:00 UTC";
        }
    });
