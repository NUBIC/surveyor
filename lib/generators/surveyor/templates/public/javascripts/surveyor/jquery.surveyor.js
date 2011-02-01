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
  jQuery("form#survey_form input, form#survey_form select, form#survey_form textarea").change(function(){
    question_data = $(this).parents('fieldset[id^="q_"]').find("input, select, textarea").serialize();
    // console.log(unescape(question_data));
    $.ajax({ type: "PUT", url: $(this).parents('form#survey_form').attr("action"), data: question_data, dataType: 'json', success: successfulSave })
  });
  // }
  
  // If javascript works, we don't need to show dependents from previous sections at the top of the page.
  jQuery("#dependents").remove();
  
  function successfulSave(responseText){ // for(key in responseText) { console.log("key is "+[key]+", value is "+responseText[key]); }
    // surveyor_controller returns a json object to show/hide elements and insert/remove ids e.g. {"ids": {"2" => 234}, "remove": {"4" => 21}, "hide":["question_12","question_13"],"show":["question_14"]}
    jQuery.each(responseText.show, function(){ jQuery('#' + this).show("fast"); });
    jQuery.each(responseText.hide, function(){ jQuery('#' + this).hide("fast"); });
    jQuery.each(responseText.ids, function(k,v){ jQuery('#r_'+k+'_question_id').after('<input id="r_'+k+'_id" type="hidden" value="'+v+'" name="r['+k+'][id]"'); });
    jQuery.each(responseText.remove, function(k,v){ jQuery('#r_'+k+'_id[value="'+v+'"]').remove(); });
    return false;
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
  
  $('li.date input').dateinput();
});
