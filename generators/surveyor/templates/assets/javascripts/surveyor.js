// Javascript UI for surveyor
jQuery(document).ready(function(){

	if(jQuery.browser.msie){
		// IE has trouble with the change event for form radio/checkbox elements - bind click instead
		jQuery("form#survey_form input[type=radio], form#survey_form [type=checkbox]").bind("click", function(){ 
			jQuery(this).parents("form").ajaxSubmit({dataType: 'json', success: successfulSave});
		});
		// IE fires the change event for all other (not radio/checkbox) elements of the form
		jQuery("form#survey_form *").not("input[type=radio], input[type=checkbox]").bind("change", function(){ 
			jQuery(this).parents("form").ajaxSubmit({dataType: 'json', success: successfulSave});	
		});
	}else{
		// Other browsers just use the change event on the form
		jQuery("form#survey_form").bind("change", function(){ jQuery(this).ajaxSubmit({dataType: 'json', success: successfulSave});	return false; });		
	}
	
	// If javascript works, we don't need to show dependents from previous sections at the top of the page.
	jQuery("#dependents").remove();

	function successfulSave(responseText){ // for(key in responseText) { console.log("key is "+[key]+", value is "+responseText[key]); }
		// surveyor_controller returns a json object to show/hide elements e.g. {"hide":["question_12","question_13"],"show":["question_14"]}
		jQuery.each(responseText.show, function(){ jQuery('#' + this).show("fast");	});
		jQuery.each(responseText.hide, function(){ jQuery('#' + this).hide("fast");	});
		return false;
	}
	
	// is_exclusive checkboxes should disble sibling checkboxes
	$('input.exclusive:checked').parents('.answer').siblings().find(':checkbox').attr('checked', false).attr('disabled', true);
	$('input.exclusive:checkbox').click(function(){
    var e = $(this);
    var others = e.parents('.answer').siblings().find(':checkbox');
    if(e.is(':checked')){
      others.attr('checked', false).attr('disabled', true);
    }else{
      others.attr('disabled', false);
    }
  });

});
