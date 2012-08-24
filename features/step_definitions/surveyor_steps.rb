When /^I start the "([^"]*)" survey$/ do |name|
  steps %Q{
    When I go to the surveys page
    Then I should see "#{name}\"
    When I press "Take it"
  }
end

When /^I start the survey$/ do
  steps %Q{
    When I go to the surveys page
     And I press "Take it"
  }
end

# When I fill in the (nth) (string) for "(ref_id)" with "(value to fill)"
When /^I fill in the (\d+[a-z]{0,2} )?(\w+) for "([^"]+)" with "([^"]+)"$/ do |index, type, answer_reference_id, value|
  answer = Answer.where(:reference_identifier => answer_reference_id).first
  fail "No answer with ref ID #{answer_reference_id.inspect}" unless answer

  i = index ? index.to_i - 1 : 0

  answer_input_id = page.all("input[@value='#{answer.id}']").
    select { |x| x['id'] =~ /answer_id/ }[i]['id']
  ordinal = answer_input_id.scan(/r_(\d+)/).first.first
  value_input_id = "r_#{ordinal}_#{type}_value"
  page.fill_in(value_input_id, :with => value)
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
  q = Question.find_by_text(text)
  page.should_not have_css %(fieldset#q_#{q.id}.q_hidden)
end

Then /^the question "(.*?)" should be hidden$/ do |text|
  q = Question.find_by_text(text)
  page.should have_css %(fieldset#q_#{q.id}.q_hidden)
end

Then /^there should be (\d+) response with answer "([^"]*)"$/ do |count, answer_text|
  Response.count.should == count.to_i
  Response.find_by_answer_id(Answer.find_by_text(answer_text)).should_not be_blank
end

When /^I choose row (\d+), column (\d+) of the grid$/ do |row, col|
  find(".g_grid").find("tr:nth-child(#{row.to_i + 1})").find("td:nth-child(#{col.to_i + 1})").find("input").set(true)
end

Then /^there should (not )?be a (\w+ )?response(?: for answer "([^"]+)")?(?: with value "([^"]+)")?(?: on question "([^"]+)")?$/ do |neg, type, answer_reference_id, value, question_reference_id|
  conditions = []
  values = []
  expected_count = neg.blank? ? 1 : 0
  if type
    attribute = case type.strip
                when 'date'
                  'datetime_value'
                when 'time'
                  'datetime_value'
                else
                  "#{type.strip}_value"
                end
    if value
      case type.strip
      when 'date'
        # Work around deficient SQLite date handling
        conditions << "date(#{attribute}) = date(?)"
        values << value
      else
        conditions << "#{attribute} = ?"
        values << value
      end
    else
      conditions << "#{attribute} IS NOT NULL"
    end
  end

  if question_reference_id
    question = Question.where(:reference_identifier => question_reference_id).first
    fail "No question with ref ID #{question_reference_id}" unless question
    conditions << 'question_id = ?'
    values << question
  end

  if answer_reference_id
    a_conds = { :reference_identifier => answer_reference_id }
    if question
      a_conds[:question_id] = question
    end
    answer = Answer.where(a_conds).first
    fail "No answer with ref ID #{answer_reference_id}" unless answer
    conditions << 'answer_id = ?'
    values << answer
  end

  Response.where(conditions.join(' AND '), *values).count.should == expected_count
end

Then /^I should see the image "([^"]*)"$/ do |src|
  page.should have_selector %(img[src^="#{src}"])
end

Then /^I click elsewhere$/ do
  page.find('.survey_title').click
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

Then /^the json for the ([^"]*) response set for "([^"]*)" should be$/ do |order, title, string|
  response_sets = ResponseSet.joins(:survey).where(:surveys => { :title => title }).order(:updated_at)
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

Then /^the json for the ([^"]*) response set for "(.*?)" should include '(.*?)'$/ do |order, title, string|
  response_sets = ResponseSet.joins(:survey).where(:surveys => { :title => title }).order(:updated_at)
  response_sets.should_not be_empty

  case order
  when "last"
    response_set = response_sets.last
  when "first"
    response_set = response_sets.first
  end
  response_set.should_not be_nil
  visit "/surveys/#{response_set.survey.access_code}/#{response_set.access_code}.json"

  page.find('body').text.include?(string).should == true
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

Then /^I should see (\d+) textareas on the page$/ do |i|
  page.has_css?('textarea', :count => i)
end

Then /^I should see (\d+) "(.*?)" input on the page$/ do |i, css_class|
  page.has_css?("input.#{css_class}", :count => i)
end

Then /^I should see (\d+) select on the page$/ do |i|
  page.has_css?("select", :count => i)
end

Then /^the checkbox for "(.*?)" should be (dis|en)abled$/ do |text, dis_or_en|
  a = Answer.find_by_text(text)
  a.should_not be_nil
  element = find("input[value='#{a.id}']")
  if dis_or_en == 'dis'
    element['disabled'].should == 'true'
  else
    [nil, 'false'].should include(element['disabled'])
  end
end

# see support/simultaneous_ajax.rb
Then /^I wait for things to settle out( longer)?$/ do |longer|
  if @simultaneous_ajax
    Capybara.timeout(longer ? 120 : 10, page.driver, "waiting for all AJAX requests timed out") do
      page.evaluate_script("window.surveyorIntegratedTestsRequestsOutstanding <= 0")
    end
  end
end
