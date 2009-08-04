// Javascript source to drive the UI for the survey engine

// Hooking up after the page loads
jQuery(document).ready(function(){
  /******** Event hooks ******/

  // Attaching to the primary survey form to do async postbacks 
  //options object
  var options = {  
    dataType:        'json', 
    success:      successfulSave
  };

  function successfulSave(responseText){
    jQuery.each(responseText.show, function(){
      jQuery('#' + this).show("slow");
    });
    jQuery.each(responseText.hide, function(){
      jQuery('#' + this).hide("slow");
    });
    return false;
  }

  jQuery("form#survey_form").bind("change", function(){
    //jQuery(this).ajaxSubmit(options);
    var this_form = jQuery(this);
    var post_data = this_form.serialize();
    jQuery.post(this_form.attr("action"),post_data);
    return false;
  });

  jQuery("#dependents").remove();


});
