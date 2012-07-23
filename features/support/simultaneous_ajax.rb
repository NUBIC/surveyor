require 'selenium/webdriver'

Before('@simultaneous_ajax') do
  @simultaneous_ajax = true
  Capybara.current_driver = :selenium_nowait
end

After('@simultaneous_ajax') do
  Capybara.use_default_driver
  @simultaneous_ajax = false
end

class AjaxRefCountListener < Selenium::WebDriver::Support::AbstractEventListener
  def refcount_key
    'surveyorIntegratedTestsRequestsOutstanding'
  end

  def call(*args)
    event = args.unshift
    driver = args.pop
    unless event.to_s =~ /script/ # prevent infinite recursion
      enable_ajax_call_refcount_if_necessary(driver)
    end
  end

  def enable_ajax_call_refcount_if_necessary(driver)
    unless driver.execute_script "return window.hasOwnProperty('#{refcount_key}')"
      enable_ajax_call_refcount(driver)
    end
  end

  # Taken wholesale from the resynchronize code in Capybara's Selenium driver.
  # Replicated here because the Capybara implementation doesn't let you make
  # multiple interactions issuing separate AJAX calls and then wait for all of
  # them — it can only wait for those AJAX requests issued in the context of a
  # single interaction (a click, etc.).
  def enable_ajax_call_refcount(driver)
    driver.execute_script <<-JS
      window.#{refcount_key} = 0;
      (function() { // Overriding XMLHttpRequest
          var oldXHR = window.XMLHttpRequest;

          function newXHR() {
              var realXHR = new oldXHR();

              window.#{refcount_key}++;
              realXHR.addEventListener("readystatechange", function() {
                  if( realXHR.readyState == 4 ) {
                    setTimeout( function() {
                      window.#{refcount_key}--;
                      if(window.#{refcount_key} < 0) {
                        window.#{refcount_key} = 0;
                      }
                    }, 500 );
                  }
              }, false);

              return realXHR;
          }

          window.XMLHttpRequest = newXHR;
      })();
    JS
  end
end

# Provides an alternative selenium driver with resync off and refcounting on.
# This allows for simulation of competing AJAX requests.
Capybara.register_driver :selenium_nowait do |app|
  Capybara::Selenium::Driver.new(app, :browser => ENV['SELENIUM_BROWSER'].to_sym,
    :resynchronize => false, :listener => AjaxRefCountListener.new)
end
