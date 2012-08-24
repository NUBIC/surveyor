require 'capybara/selenium/driver'

##
# Subclass of `Capybara::Selenium::Driver` that ensures that quit is only called
# once.
#
# This is necessary because there is code in the Firefox selenium bridge which
# reacts poorly if its quit method is called more than once. The
# @simultaneous_ajax support for the duplicate check features requires a
# separate selenium driver instance, which in turn requires directly calling
# quit on the running driver when switching between them.
#
# Capybara::Selenium::Driver registers an `at_exit` hook which isn't removed
# when you call quit. This results in quit being called twice for some driver
# instances, provoking the issue with Firefox.
class SingleQuitSeleniumDriver < Capybara::Selenium::Driver
  def quit
    unless @already_quit
      super
      @already_quit = true
    end
  end
end
