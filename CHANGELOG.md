History for Surveyor
====================

1.5.0
-----

### Features

* Putting social contract up front
* Support strong parameters in Rails 4.0, whitelisted attributes in Rails 3.2
* allow full version specifications in ENV, e.g. RAILS_VERSION=3.2.0

### Testing

* moving CI to Travis
* moving integration tests to RSpec from cucumber
* using PhantomJS and Poltergeist for headless JS testing

### Dependencies

* Adding support for Rails 4.0 and removing support for Rails 3.1. Applications requiring Rails 3.1 should use Surveyor v1.4.1
* Removing support for Ruby 1.8.7 and Ruby 1.9.3. Applications requiring Ruby 1.x shoudl use Survyeor v1.4.1

### Fixes

* updating README and stacktests
* moving redcap feature to redcap spec
* removing surveyor_parser.feature (integrated into parser_spec)
* moving parser cucumber feature to parser spec. moving fixture surveys to fixture directory
* respect :clean_with_truncation
* remove benchmark spec
* default rails version (#472)
* fix deprecation warnings about Hash#diff
* fix deprecation warnings about find_all_by_ dynamic finder
* fix deprecation warnings about the :value option
* fix deprecation warnings about #find(:first)
* fix regexp serialization
* kludge: load formtastic enhancements explicitly
* fix slow_updates monkey patch
* Hash#diff is deprecated
* use surveyor common operators instead of aliasing them through a class method in ValidationCondition
* refactoring classes with ActiveSupport::Concern
* fixing next section button
* remove already disabled section caching
* fix code that figures out if the asset pipeline is enabled
* move images to where sprockets expects them to be
* removed "unloadable" declarations
* fix deprecation warnings relating to has_many declarations
* fix deprecation warnings about calling scope() with a hash
* fix deprecation warnings about calling find_by with options
* refactor call to find(:first) to quiet deprecation warnings
* replace Relation#all with other methods to quiet deprecation warnings
* replace rspec stub!() with stub() to quiet deprecation warnings
* Make #to_formatted_s handle nils in datetime_value (#459)
* Update kitchen_sink_survey.r (#458)
* Fix migration (#454)
* Allow date_value= and time_value= to handle nils (#450)

1.4.1
-----

### Fixes

- Handle `nil` in `ResponseMethods#date_value=` and `ResponseMethods#time_value`.
  (#450)
- Handle `nil` datetime values in `ResponseMethods#to_formatted_s`.  (#459)

### Dependencies

- Removing support for Ruby 1.8.7. Applications requiring Ruby 1.8.7 should use Surveyor v1.4.0

1.4.0
-----
### Features

- Routes are namespaced (e.g. `surveyor.available_surveys_path`) and may be mounted at a different root (e.g. `mount Surveyor::Engine, :at => '/instruments'`) (#398, #421)
- Surveyor::Parser.parse_file takes an options[:filename] parameter, used to locate translations (#429)
- Surveyor::Parser allows translations to be specified inline using a hash (#429)
- require locale of survey when translations are present (#426)
- locale selection in survey UI (#427)

### Fixes

- Remove default order on Response. (#423)
- Bug fix for RedCap Parser for DependencyConditions. thanks @ariel-perez-birchbox
- Make Surveyor::Parser accept Answer#reference_identifier via underscore or hash syntax (#439)
- Fix show action and have it use new translation view methods (#438, #442) thanks @alanjcfs
- Fix times showing in UTC when time zone is specified in Rails (#435)

### Dependencies

- Removing support for Rails 3.0. Applications requiring Rails 3.0 should use Surveyor v1.3.0

1.3.0
-----

### Features

- Upgrade to jQuery UI 1.10.0, jQuery 1.9.0, jQueryUI timepicker addons 1.2, and remove jQuery tools (#409)
- Upgrade reset css
- Added surveyor_translations table to support YAML-based localizations of surveys. (#420)
- Add extension point for pre-JSON-export survey modifications (#416)
- Add input mask for text entry fields (#415)

### Fixes

- Export null when datetime response has null datetime value
- Move the help text to be after the answer text (#401)
- Fix response serialization for date pick one answers (#400)
- Remove ordering default scope on survey section methods (#417, #290)
- Answers of labels should not be shown, within or without groups (#304)
- Inline group questions should display inline (#303)
- Evaluate all submitted questions for depdencies (#396)
- Pick one answers with dates should display their dates correctly (#378)

### Infrastructure

- Added stacktests.sh shell script for testing different stacks

1.2.0
-----

### Features

- Allow rendering of simple hash contexts with Mustache (#296)
- Allow configuration of question numbering (#136)
- Allow references to question_ and answer_ in dependency conditions (#345)

### Fixes

- Surveyor will never require 'fastercsv' on Ruby 1.9. (#381)
- Add question_groups/question/answer/reference_identifier to JSON
  serialization for Survey. (#390)
- Evaluate dependencies even when the last response is removed (#362, #215)
- Add answer help text (#373)
- SurveyorController#export now renders 404 when surveys are not found (#391)

1.1.0
-----

### Features

- Breaking change: Question#is_mandatory => false by default. For those who found it useful to have
  all questions mandatory, the parser accepts `:default_mandatory => true` as an argument to the survey.

### Fixes

- fixing and documenting count operators on dependency conditions

### Infrastructure

- basic spec for the surveyor task

1.0.1
------

### Features

- Question#display_type == "hidden" and QuestionGroup#display_type == "hidden"
  now exclude the question or question group from the DOM. These display types are
  used to inject data (responses) into surveys. Note, custom_class => "hidden" doesn't
  have any effect until a custom css rule is created by the end user. (#197)

- more readable parser and more strict parser method aliases (#278)

### Fixes

- Replaced deprecated ActiveRecord::Errors#each_full with ActiveRecord::Errors#full_messages. (#363)

- fixing dependency condition evaluation where #Response.*_value is nil. (#297)

- fixing grid answers leak, introduced in 5baa7ac3. thanks @jsurrett (#375, #377)

1.0.0
------

### Features

- Official support for Rails 3.2, including declaring of all mass-assignable
  attributes with `attr_accessible`.

- Breaking change: Surveys are now explicitly versioned. If you loaded a survey
  when another survey with the same title/access code had already been loaded,
  Surveyor would previously have appended a serial number to the title. As of
  this version, Surveyor keeps the serial number in a separate `survey_version`
  field. (#262)

- Add encoding comments for generated files. (#329)

- Asset pipeline support for Rails 3.1+. Rails 3.0 is still supported.
  (#307, #314, #315)

- Upgrade to Formtastic 2.1. (#227)

- `:pick => :one` and `:pick => :any` questions may now have date, time,
  datetime, integer, or float values, in addition to the already-supported
  string values. (#207)

- Added Survey#as_json, ResponseSet#as_json. (#291)

- Changed defaults for and interpretation of for Survey#active_at and
  Survey#inactive_at. (#258)

- JSON export representation of DateTimes is 2010-04-08T10:30+00:00 and Dates is
  2010-04-08 and Times is 10:30. (#355)

- JSON representation of Response includes response_group. (#349)

- Use Object#extend to inject SuryeyorParser and SurveyorRedcapParser methods into
  instances of models instead of reopening classes. Move responsibility for keeping
  track of and reporting duplicate and bad references from the models to the parsers.
  Upgrade SurveyorRedcapParser to trace only when rake --trace is specified. (#341)

- export Question#data_export_identifier, Answer#data_export_identifier,
  Answer#reference_identifier in survey JSON export. (#368)

### Fixes

- Ensure response set is available to `render_context` (#320)

- Hide dependent rows of grids. (#343)

- Dependency condition with '!=' now returns true if there is no response. (#337)

- Properly handle multiple "exclusive" checkboxes in a single question. (#336)

- Correct storing of "correct" answers when parsing a survey. (#326)

- Restore "slider" renderer. (#230)

- Ensure that duplicate responses cannot be created by parallel AJAX requests.
  (#328)

- Create default identifiers in before_create, not in the initializer. (#369)

- Eliminate unnecessary (and incorrect) access code uniqueness checks.
  Use SecureRandom for generating access codes. (#370)

- Use json_spec for testing JSON responses, instead of
  Surveyor::Common#deep_compare_excluding_wildcards. (#350)

- Parser now sets Question#correct_answer_id correctly. The association is changed from
  Question :has_one correct_answer => Question :belongs_to correct_answer. (#365)

### Infrastructure

- Enabled Selenium-backed cucumber features in CI. (#333)

- Added `testbed:surveys` task to load all sample surveys in the testbed.

- Begin formal changelog.

- Change test infra so that tx behavior can be tested. (#360)
