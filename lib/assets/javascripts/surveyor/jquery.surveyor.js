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
    timeFormat: 'HH:mm:ss',
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

  jQuery(document).on("change", ".surveyor_check_boxes input[type=text]", function(){
    var textValue = $(this).val()
    if (textValue.length > 0) {
      $(this).parent().children().has('input[type="checkbox"]')[0].children[0].checked = true;
    }
  });

  jQuery(document).on("change", ".surveyor_radio input[type=text]", function(){
    var textValue = $(this).val()
    if (textValue.length > 0) {
      $(this).parent().children().has('input[type="radio"]')[0].children[0].checked = true;
    }
  });

  jQuery(document).on("change", "form#survey_form input, form#survey_form select, form#survey_form textarea", function(){
    var elements = [$('[type="submit"]').parent(), $('[name="' + this.name +'"]').closest('li')];

    question_data = $(this).parents('fieldset[id^="q_"],tr[id^="q_"]').
      find("input, select, textarea").
      add($("form#survey_form input[name='authenticity_token']")).
      serialize();
    $.ajax({
      type: "PUT",
      url: $(this).parents('form#survey_form').attr("action"),
      data: question_data, dataType: 'json',
      success: function(response) {
        successfulSave(response);
      }
    });
  });

  // http://www.filamentgroup.com/lab/update_jquery_ui_slider_from_a_select_element_now_with_aria_support/
  $('fieldset.q_slider select').each(function(i,e) {
    $(e).selectToUISlider({"labelSrc": "text"}).hide()
  });

  // If javascript works, we don't need to show dependents from
  // previous sections at the top of the page.
  jQuery("#dependents").remove();

  function successfulSave(responseText) {
    jQuery.each(responseText.show, function(){ showElement(this) });
    jQuery.each(responseText.hide, function(){
      var response_element = $("#"+this);
      if ( response_element.length > 0 ) {
        var element             = response_element.find(":input:not([type=hidden])");
        var collapsable_buttons = response_element.find(".btn.surveydetail");
        var detail_info         = response_element.find(".in.collapse");

        if ( element ) {
          if($(element).is(":checkbox") || $(element).is(":radio")){
            $(element).attr("checked", false);
          }else{
            $(element).val('');
          }
        }

        if ( collapsable_buttons ){
          $(collapsable_buttons).addClass('collapsed');
        }

        if ( detail_info ){
          $(detail_info).collapse('hide');
        }
        hideElement(this);
      }
    });
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
      question_id = id.match(/\d+/);
      removeUselessResponse(question_id);
    }
  }

  function removeUselessResponse(id){
    $.ajax({
      type: "DELETE",
      dataType: 'json',
      url: $('form#survey_form').attr("action") + "/" + id,
      success: function(response) {
        successfulSave(response);
      }
    });
  }

  // is_exclusive checkboxes should disble sibling checkboxes
  $('input.exclusive:checked').parents('fieldset[id^="q_"]').
    find(':checkbox').
    not(".exclusive").
    attr('checked', false).
    attr('disabled', true);

  $('input.exclusive:checkbox').click(function(){
    var e = $(this);
    var others = e.parents('fieldset[id^="q_"]').find(':checkbox').not(e);
    if(e.is(':checked')){
      others.attr('checked', false).attr('disabled', 'disabled');
    }else{
      others.attr('disabled', false);
    }
  });

  jQuery("input[data-input-mask]").each(function(i,e){
    var inputMask = $(e).attr('data-input-mask');
    var placeholder = $(e).attr('data-input-mask-placeholder');
    var options = { placeholder: placeholder };
    $(e).mask(inputMask, options);
  });

  // translations selection
  $(".surveyor_language_selection").show();
  $(".surveyor_language_selection select#locale").change(function(){ this.form.submit(); });

});
