When /^I start the "([^"]*)" survey$/ do |name|
  steps %Q{
    When I go to the surveys page
    Then I should see "#{name}\"
    When I press "Take it"
  }
end

Then /^there should be (\d+) response set with (\d+) responses? with:$/ do |rs_num, r_num, table|
  ResponseSet.count.should == rs_num.to_i
  Response.count.should == r_num.to_i
  table.hashes.each do |hash|
    if hash.keys == ["answer"]
      a = Answer.find_by_text(hash["answer"])
      a.should_not be_nil
      Response.first(:conditions => {:answer_id => a.id}).should_not be_nil
    else
      if !(a = hash.delete("answer")).blank? and !(answer = Answer.find_by_text(a)).blank?
        Response.first(:conditions => hash.merge({:answer_id => answer.id})).should_not be_nil
      elsif
        Response.first(:conditions => hash).should_not be_nil
      end
    end
  end
end

Then /^there should be (\d+) dependenc(?:y|ies)$/ do |x|
  Dependency.count.should == x.to_i
end

Then /^question "([^"]*)" should have a dependency with rule "([^"]*)"$/ do |qr, rule|
  q = Question.find_by_reference_identifier(qr)
  q.should_not be_blank
  q.dependency.should_not be_nil
  q.dependency.rule.should == rule
end

Then /^the element "([^"]*)" should have the class "([^"]*)"$/ do |selector, css_class|
  page.should have_selector(selector, :class => css_class)
end

Then /^the element "([^"]*)" should exist$/ do |selector|
  page.should have_selector(selector)
end

Then /^the survey should be complete$/ do
  ResponseSet.first.should be_complete
end

Then /^a dropdown should exist with the options "([^"]*)"$/ do |options_text|
  page.should have_selector('select')
  options = options_text.split(',').collect(&:strip)
  within "select" do |select|
    options.each do |o|
      select o
    end
  end
end

Then /^there should be (\d+) checkboxes$/ do |count|
  page.should have_selector('input[type=checkbox]', :count => count.to_i)
end

Then /^there should be (\d+) text areas$/ do |count|
  page.should have_selector('textarea', :count => count.to_i)
end

Then /^the question "([^"]*)" should be triggered$/ do |text|
  page.should have_selector %(fieldset[name="#{text}"][class!="q_hidden"])
end

Then /^there should be (\d+) response with answer "([^"]*)"$/ do |count, answer_text|
  Response.count.should == count.to_i
  Response.find_by_answer_id(Answer.find_by_text(answer_text)).should_not be_blank
end

Then /^there should be a datetime response with today's date$/ do
  # Response.datetime_value returns ActiveSupport::TimeWithZone
  # so we call .to_date on it for the comparison with Date.today
  Response.all.one?{|x| x.datetime_value.to_date == Date.today}.should be_true
end

Then /^I should see the image "([^"]*)"$/ do |src|
  page.should have_selector %(img[src^="#{src}"])
end

Then /^(\d+) responses should exist$/ do |response_count|
  Response.count.should == response_count.to_i
end

Then /^the json for "([^"]*)" should be$/ do |title, string|
  visit "/surveys/#{Survey.to_normalized_string(title)}.json"
  puts page.find('body').text
  Surveyor::Common.equal_json_excluding_wildcards(page.find('body').text, string).should == true
end

Then /^the json for "([^"]*)" version "([^"]*)" should be$/ do |title, version, string|
  visit "/surveys/#{Survey.to_normalized_string(title)}.json?survey_version=#{version}"
  puts page.find('body').text
  Surveyor::Common.equal_json_excluding_wildcards(page.find('body').text, string).should == true
end

Then /^the json for the "([^"]*)" response set for "([^"]*)" should be$/ do |order, title, string|
  response_sets = ResponseSet.joins(:survey).where(:conditions => { :surveys => { :title => title }}).order(:updated_at)
  response_sets.should_not be_empty
  
  case order
  when "last"
    response_set = response_sets.last
  when "first"
    response_set = response_sets.first
  end
  response_set.should_not be_nil    
  visit "/surveys/#{response_set.survey.access_code}/#{response_set.access_code}.json"
  Surveyor::Common.equal_json_excluding_wildcards(page.find('body').text, string).should == true
end

Then /the element "([^\"]*)" should be hidden$/ do |selector|
  wait_until do
    its_hidden = page.evaluate_script("$('#{selector}').is(':hidden');")
    its_not_in_dom = page.evaluate_script("$('#{selector}').length == 0;")
    (its_hidden || its_not_in_dom).should be_true
  end
end

Then /the element "([^\"]*)" should not be hidden$/ do |selector|
  wait_until do
    its_not_hidden = page.evaluate_script("$('#{selector}').is(':not(:hidden)');")
    its_in_dom = page.evaluate_script("$('#{selector}').length > 0;")
    (its_not_hidden && its_in_dom).should be_true
  end
end
Given /^I have survey context of "([^"]*)"$/ do |context|
  class SurveyorController < ApplicationController
    require 'mustache'
    class FakeMustacheContext < ::Mustache
      def name
        "Santa Claus"
      end
      def site
        "Northwestern"
      end
    end
    def render_context
      FakeMustacheContext
    end
  end
end

When /^I follow today's date$/ do
  steps %Q{
    When I follow "#{Date.today.strftime('%d').to_i}"
  }
end
