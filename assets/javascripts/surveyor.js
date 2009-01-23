// Javascript source to drive the UI for the survey engine

// Hooking up after the page loads
$(document).ready(function(){
  /******** Event hooks ******/

  // Attaching to the primary survey form to do async postbacks 
  //options object
  var options = {  
    dataType:        'json', 
    success:      successfulSave
  };

  function successfulSave(responseText){
    jQuery.each(responseText.show, function(){
      $('#' + this).show("slow");
    });
    jQuery.each(responseText.hide, function(){
      $('#' + this).hide("slow");
    });
    return false;
  }

  $("form#survey_form").bind("change", function(){
    $(this).ajaxSubmit(options);
  });
  $("#dependents").remove();


});