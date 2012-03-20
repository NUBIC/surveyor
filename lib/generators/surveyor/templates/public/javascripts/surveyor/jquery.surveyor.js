// Javascript UI for surveyor
jQuery(document).ready(function(){
  // if(jQuery.browser.msie){
  //  // IE has trouble with the change event for form radio/checkbox elements - bind click instead
  //  jQuery("form#survey_form input[type=radio], form#survey_form [type=checkbox]").bind("click", function(){
  //    jQuery(this).parents("form").ajaxSubmit({dataType: 'json', success: successfulSave});
  //  });
  //  // IE fires the change event for all other (not radio/checkbox) elements of the form
  //  jQuery("form#survey_form *").not("input[type=radio], input[type=checkbox]").bind("change", function(){
  //    jQuery(this).parents("form").ajaxSubmit({dataType: 'json', success: successfulSave});
  //  });
  // }else{
  //  // Other browsers just use the change event on the form

  //
  // Uncomment the following to use the jQuery Tools Datepicker (http://jquerytools.org/demos/dateinput/index.html)
  // instead of the default jQuery UI Datepicker (http://jqueryui.com/demos/datepicker/)
  //
  // For a date input, i.e. using dateinput from jQuery tools, the value is not updated
  // before the onChange or change event is fired, so we hang this in before the update is
  // sent to the server and set the correct value from the dateinput object.
  // jQuery('li.date input').change(function(){
  //     if ( $(this).data('dateinput') ) {
  //         var date_obj = $(this).data('dateinput').getValue();
  //         this.value = date_obj.getFullYear() + "-" + (date_obj.getMonth()+1) + "-" +
  //             date_obj.getDate() + " 00:00:00 UTC";
  //     }
  // });
  //
  // $('li input.date').dateinput({
  //     format: 'dd mmm yyyy'
  // });
  
  // Default Datepicker uses jQuery UI Datepicker 
  jQuery("input[type='text'].datetime").datetimepicker({
  	showSecond: true,
  	showMillisec: false,
  	timeFormat: 'hh:mm:ss',
  	dateFormat: 'yy-mm-dd',
  	changeMonth: true,
  	changeYear: true
  });
  jQuery("li.date input").datepicker({ 
  	dateFormat: 'yy-mm-dd',
  	changeMonth: true,
  	changeYear: true
  });
  jQuery("input[type='text'].date").datepicker({ 
  	dateFormat: 'yy-mm-dd',
  	changeMonth: true,
  	changeYear: true
  });
  jQuery("input[type='text'].datepicker").datepicker({ 
  	dateFormat: 'yy-mm-dd',
  	changeMonth: true,
  	changeYear: true
  });
  jQuery("input[type='text'].time").timepicker({});
  
  jQuery('.surveyor_check_boxes input[type=text]').change(function(){
    var textValue = $(this).val()
    if (textValue.length > 0) {
      $(this).parent().children().has('input[type="checkbox"]')[0].children[0].checked = true;
    }
  });
  
  jQuery('.surveyor_radio input[type=text]').change(function(){
    var textValue = $(this).val()
    if (textValue.length > 0) {
      $(this).parent().children().has('input[type="radio"]')[0].children[0].checked = true;      
    }
  });

  jQuery("form#survey_form input, form#survey_form select, form#survey_form textarea").change(function(){
    var elements = [$('[type="submit"]').parent(), $('[name="' + this.name +'"]').closest('li')];
    blockElements(elements);
    
    question_data = $(this).parents('fieldset[id^="q_"],tr[id^="q_"]').find("input, select, textarea").add($("form#survey_form input[name='authenticity_token']")).serialize();
    // console.log(unescape(question_data));
    $.ajax({ 
      type: "PUT", 
      url: $(this).parents('form#survey_form').attr("action"), 
      data: question_data, dataType: 'json', 
      success: function(response) {
        unblockElements(elements);
        successfulSave(response);
      }, 
      error: function(xhr, ajaxOptions, thrownError) {
        unblockElements(elements);
      }
    });
  });

  // If javascript works, we don't need to show dependents from previous sections at the top of the page.
  jQuery("#dependents").remove();

  function successfulSave(responseText){ // for(key in responseText) { console.log("key is "+[key]+", value is "+responseText[key]); }
    // surveyor_controller returns a json object to show/hide elements and insert/remove ids e.g. {"ids": {"2" => 234}, "remove": {"4" => 21}, "hide":["question_12","question_13"],"show":["question_14"]}
    jQuery.each(responseText.show, function(){ showElement(this) });
    jQuery.each(responseText.hide, function(){ hideElement(this) });
    jQuery.each(responseText.ids, function(k,v){ jQuery('#r_'+k+'_question_id').after('<input id="r_'+k+'_id" type="hidden" value="'+v+'" name="r['+k+'][id]"/>'); });
    jQuery.each(responseText.remove, function(k,v){ jQuery('#r_'+k+'_id[value="'+v+'"]').remove(); });
    return false;
  }
  
  function showElement(id){
    group = id.match('^g_') ? true : false;
    if (group) {
      jQuery('#' + id).removeClass("g_hidden");
    } else {
      jQuery('#' + id).removeClass("q_hidden");
    }
  }
  
  function hideElement(id){
    group = id.match('^g_') ? true : false;
    if (group) {
      jQuery('#' + id).addClass("g_hidden");
    } else {
      jQuery('#' + id).addClass("q_hidden");
    }
  }
  
  function blockElements(elements) {
    $.blockUI.defaults.overlayCSS.opacity = 0;
    $.blockUI.defaults.message = null;
    $.blockUI.defaults.fadeIn = 0;
    $.blockUI.defaults.fadeOut = 0;
    $.each(elements, function(){ $(this).block()});
  }
  
  function unblockElements(elements) {
    $.each(elements, function(){ $(this).unblock()});
  }

  // is_exclusive checkboxes should disble sibling checkboxes
  $('input.exclusive:checked').parents('fieldset[id^="q_"]').find(':checkbox').not(".exclusive").attr('checked', false).attr('disabled', true);
  $('input.exclusive:checkbox').click(function(){
    var e = $(this);
    var others = e.parents('fieldset[id^="q_"]').find(':checkbox').not(".exclusive");
    if(e.is(':checked')){
      others.attr('checked', false).attr('disabled', true);
    }else{
      others.attr('disabled', false);
    }
  });
});
