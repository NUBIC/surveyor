require 'selenium/webdriver'

Before('~@simultaneous_ajax') do
  evict_capybara_session :selenium_nowait
end

Before('@simultaneous_ajax') do
  evict_capybara_session :selenium

  @simultaneous_ajax = true
  Capybara.javascript_driver = Capybara.current_driver = :selenium_nowait
end

After('@simultaneous_ajax') do
  Capybara.javascript_driver = nil
  @simultaneous_ajax = false
end

# Evict the "other" selenium driver's session when switching drivers because it
# seems that WebDriver can't handle having two different browsers open
# simultaneously. Specifically, if you:
#
#   * Run a test with driver A, then
#   * Run set of tests with driver B, then
#   * Attempt to run a test with driver A
#
# ... the final driver A test will hang attempting to contact some piece of the
# webdriver infrastructure. It will hang until it times out, or until you
# kill the browser associated with driver B. This code does the killing for
# you.
def evict_capybara_session(driver_name)
  Capybara.instance_eval do
    key = session_pool.keys.grep(/^#{driver_name}\:/).first
    if key
      session = session_pool.delete(key)
      puts "key=#{key} evicting session #{session.object_id} driver #{session.driver.object_id}"
      session.driver.quit
    end
  end
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
  SingleQuitSeleniumDriver.new(app, :browser => ENV['SELENIUM_BROWSER'].to_sym,
    :resynchronize => false, :listener => AjaxRefCountListener.new)
end
