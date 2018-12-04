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

  var SurveyorAjax,
      __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  SurveyorAjax = function() {
    this.bindAll(["beforeSend", "success", "done"]);
    this.init();
  }

  $.extend(SurveyorAjax, {

    prototype: {

      bindAll: function( fns ){
        var fn, _i, _len;
        for (_i = 0, _len = fns.length; _i < _len; _i++) {
          fn = fns[_i];
          this[fn] = __bind(this[fn], this);
        }
      },

      init: function(){
        this.options = {};
        this.setOptions();
        this.buildSurveyorCallbacks();
        this.binds();
      },

      setOptions: function() {
        this.options.type       = "PUT";
        this.options.dataType   = "json";
        this.options.url        = $('form#survey_form').attr("action");
        this.options.success    = this.success;
      },

      setOption: function( key, value ){
        this.options[key] = value;
      },

      fieldsetData: function( element ){
        return element.parents('fieldset[id^="q_"],tr[id^="q_"]').
          find("input, select, textarea").
          add($("form#survey_form input[name='authenticity_token']")).
          serialize();
      },

      sendData: function( element ) {
        var $this = this;
        var changeTimeOut = element.data('changeTimeOut');

        if (changeTimeOut) clearTimeout(changeTimeOut);

        element.data('changeTimeOut', setTimeout(function(){
          $this.setOption("beforeSend", function(xhr){ $this.beforeSend(xhr, element); });
          $this.setOption("data", $this.fieldsetData(element));
          $.ajax($this.options).done(function(data){ $this.done(data, element); });
        }, this.getTimeOut(element)));
      },

      // Prevents too many Ajax calls with sliders
      getTimeOut: function( element ) {
        var isDatepicker = element.hasClass('hasDatepicker');
        var isSlider = element.closest('fieldset').hasClass('q_slider');

        return (isDatepicker || isSlider) ? 400 : 0;
      },

      showOrHideQuestions: function( responseText ) {
        var $this = this;

        // surveyor_controller returns a json object to show/hide elements
        // e.g. {"hide":["question_12","question_13"],"show":["question_14"]}
        jQuery.each(responseText.show, function(){ $this.showElement(this) });
        jQuery.each(responseText.hide, function(){ $this.hideElement(this) });

        return false;
      },

      showElement: function( id ) { this.show(id, this.hiddenClassName(id)); },

      hideElement: function( id ) {
        var fieldset = $("#" + id);
        if (fieldset.length === 0) return false;

        var element             = fieldset.find(":input:not([type=hidden])");
        var collapsable_buttons = fieldset.find(".btn.surveydetail");
        var detail_info         = fieldset.find(".in.collapse");

        if (element) {
          this.isCheckable(element) ? element.attr("checked", false) : element.val('');
        }

        if (collapsable_buttons) collapsable_buttons.addClass('collapsed');
        if (detail_info) detail_info.collapse('hide');

        this.hide(id, this.hiddenClassName(id));
        this.removeUselessResponse(id);
      },

      hiddenClassName: function( id ) { return this.isGroup(id) ? "g_hidden" : "q_hidden" },
      isCheckable: function( element ) { return (element.is(":checkbox") || element.is(":radio")) },
      isGroup : function( id ) { return id.match('^g_') ? true : false },
      show    : function( id, className ) { $("#" + id).removeClass(className); },
      hide    : function( id, className ) { $("#" + id).addClass(className); },

      removeUselessResponse: function( id ) {
        if (this.isGroup(id)) return false;

        var id = id.match(/\d+/);

        $.ajax({
          type: "DELETE",
          dataType: 'json',
          url: this.options.url + "/" + id,
          success: this.showOrHideQuestions
        });
      },

      showLoading: function( element ){
        $(document).trigger("surveyor.showLoading", [ element ]);
      },

      hideLoading: function( element ){
        $(document).trigger("surveyor.hideLoading", [ element ]);
      },

      beforeSend: function( xhr, element ) {
        this.showLoading(element);
      },

      success: function( response ) {
        this.showOrHideQuestions( response );
      },

      done: function( data, element ) {
        this.hideLoading(element);
      },

      buildSurveyorCallbacks: function(){
        $(document).on("surveyor.binds", this.binds);
      },

      binds: function() {
        // Default Datepicker uses jQuery UI Datepicker
        jQuery("input[type='text'].datetime").datetimepicker({
          showSecond: true,
          showMillisec: false,
          timeFormat: 'HH:mm:ss',
          dateFormat: 'mm/dd/yy',
          changeMonth: true,
          changeYear: true
        });

        jQuery("li.date input").datepicker({
          dateFormat: 'mm/dd/yy',
          changeMonth: true,
          changeYear: true
        });

        jQuery("input[type='text'].date").datepicker({
          dateFormat: 'mm/dd/yy',
          changeMonth: true,
          changeYear: true
        });

        jQuery("input[type='text'].datepicker").datepicker({
          dateFormat: 'mm/dd/yy',
          changeMonth: true,
          changeYear: true
        });

        jQuery("input[type='text'].time").timepicker({});

        // http://www.filamentgroup.com/lab/update_jquery_ui_slider_from_a_select_element_now_with_aria_support/
        $('fieldset.q_slider select').each(function(i,e) {
          $(e).selectToUISlider({"labelSrc": "text"}).hide()
        });

        // If javascript works, we don't need to show dependents from
        // previous sections at the top of the page.
        jQuery("#dependents").remove();

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
      }
    }
  });

  var $surveyorAjax = new SurveyorAjax();

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
    $surveyorAjax.sendData($(this));
  });

  // translations selection
  $(".surveyor_language_selection").show();
  $(".surveyor_language_selection select#locale").change(function(){ this.form.submit(); });

});
