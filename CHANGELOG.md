History for Surveyor
====================

0.23.0
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

- Error reporting for Rails 3 (#363)

### Infrastructure

- Enabled Selenium-backed cucumber features in CI. (#333)

- Added `testbed:surveys` task to load all sample surveys in the testbed.

- Begin formal changelog.

- Change test infra so that tx behavior can be tested. (#360)
