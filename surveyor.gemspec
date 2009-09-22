# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{surveyor}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian Chamberlain", "Mark Yoon"]
  s.date = %q{2009-09-22}
  s.email = %q{yoon@northwestern.edu}
  s.files = [
    ".gitignore",
     "MIT-LICENSE",
     "Rakefile",
     "app/controllers/answers_controller.rb",
     "app/controllers/dependencies_controller.rb",
     "app/controllers/dependency_conditions_controller.rb",
     "app/controllers/questions_controller.rb",
     "app/controllers/sections_controller.rb",
     "app/controllers/surveying_controller.rb",
     "app/controllers/surveys_controller.rb",
     "app/helpers/answers_helper.rb",
     "app/helpers/application_helper.rb",
     "app/helpers/questions_helper.rb",
     "app/helpers/sections_helper.rb",
     "app/helpers/survey_form_builder.rb",
     "app/helpers/survey_importer_helper.rb",
     "app/helpers/surveying_helper.rb",
     "app/helpers/surveys_helper.rb",
     "app/models/answer.rb",
     "app/models/dependency.rb",
     "app/models/dependency_condition.rb",
     "app/models/question.rb",
     "app/models/question_group.rb",
     "app/models/response.rb",
     "app/models/response_set.rb",
     "app/models/survey.rb",
     "app/models/survey_section.rb",
     "app/models/user.rb",
     "app/views/answer_display_types/_any_answer.html.haml",
     "app/views/answer_display_types/_any_other_and_string.html.haml",
     "app/views/answer_display_types/_any_string.html.haml",
     "app/views/answer_display_types/_date.html.haml",
     "app/views/answer_display_types/_datetime.html.haml",
     "app/views/answer_display_types/_default.html.haml",
     "app/views/answer_display_types/_float.html.haml",
     "app/views/answer_display_types/_grid_any_answer.html.haml",
     "app/views/answer_display_types/_grid_default.html.haml",
     "app/views/answer_display_types/_grid_float.html.haml",
     "app/views/answer_display_types/_grid_integer.html.haml",
     "app/views/answer_display_types/_grid_one_answer.html.haml",
     "app/views/answer_display_types/_grid_string.html.haml",
     "app/views/answer_display_types/_integer.html.haml",
     "app/views/answer_display_types/_one_answer.html.haml",
     "app/views/answer_display_types/_one_string.html.haml",
     "app/views/answer_display_types/_repeater_integer.html.haml",
     "app/views/answer_display_types/_repeater_string.html.haml",
     "app/views/answer_display_types/_string.html.haml",
     "app/views/answer_display_types/_text.html.haml",
     "app/views/answer_display_types/_time.html.haml",
     "app/views/layouts/surveys.html.erb",
     "app/views/question_display_types/_default.html.haml",
     "app/views/question_display_types/_dropdown.html.haml",
     "app/views/question_display_types/_grid_default.html.haml",
     "app/views/question_display_types/_grid_dropdown.html.haml",
     "app/views/question_display_types/_group_default.html.haml",
     "app/views/question_display_types/_group_dropdown.html.haml",
     "app/views/question_display_types/_image.html.haml",
     "app/views/question_display_types/_inline.html.haml",
     "app/views/question_display_types/_label.html.haml",
     "app/views/question_display_types/_repeater_default.html.haml",
     "app/views/question_display_types/_repeater_dropdown.html.haml",
     "app/views/question_display_types/_slider.html.haml",
     "app/views/question_group_display_types/_default.html.haml",
     "app/views/question_group_display_types/_grid.html.haml",
     "app/views/question_group_display_types/_repeater.html.haml",
     "app/views/surveying/edit.html.haml",
     "app/views/surveying/finish.html.haml",
     "app/views/surveying/index.html.erb",
     "app/views/surveying/new.html.haml",
     "app/views/surveying/show.html.haml",
     "config/routes.rb",
     "init.rb",
     "install.rb",
     "lib/tasks/surveyor_tasks.rake",
     "lib/tiny_code.rb",
     "lib/user_manager.rb",
     "lib/xml_formatter.rb",
     "spec/controllers/answers_controller_spec.rb",
     "spec/controllers/dependencies_controller_spec.rb",
     "spec/controllers/dependency_conditions_controller_spec.rb",
     "spec/controllers/questions_controller_spec.rb",
     "spec/controllers/sections_controller_spec.rb",
     "spec/controllers/surveying_controller_spec.rb",
     "spec/controllers/surveying_routing_spec.rb",
     "spec/controllers/surveys_controller_spec.rb",
     "spec/fixtures/answers.yml",
     "spec/fixtures/dependencies.yml",
     "spec/fixtures/dependency_conditions.yml",
     "spec/fixtures/question_groups.yml",
     "spec/fixtures/questions.yml",
     "spec/fixtures/response_sets.yml",
     "spec/fixtures/responses.yml",
     "spec/fixtures/survey_sections.yml",
     "spec/fixtures/surveys.yml",
     "spec/fixtures/users.yml",
     "spec/helpers/survey_importer_helper_spec.rb",
     "spec/helpers/surveying_helper_spec.rb",
     "spec/models/answer_spec.rb",
     "spec/models/dependency_condition_spec.rb",
     "spec/models/dependency_spec.rb",
     "spec/models/question_group_spec.rb",
     "spec/models/question_spec.rb",
     "spec/models/response_set_spec.rb",
     "spec/models/response_spec.rb",
     "spec/models/survey_section_spec.rb",
     "spec/models/survey_spec.rb",
     "spec/models/user_spec.rb",
     "spec/rcov.opts",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "spec/views/app/edit.html.erb_spec.rb",
     "spec/views/app/index.html.erb_spec.rb",
     "spec/views/app/new.html.erb_spec.rb",
     "spec/views/app/show.html.erb_spec.rb",
     "uninstall.rb"
  ]
  s.homepage = %q{http://github.com/breakpointer/surveyor}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{A rails (gem) plugin to enable surveys in your application}
  s.test_files = [
    "spec/controllers/answers_controller_spec.rb",
     "spec/controllers/dependencies_controller_spec.rb",
     "spec/controllers/dependency_conditions_controller_spec.rb",
     "spec/controllers/questions_controller_spec.rb",
     "spec/controllers/sections_controller_spec.rb",
     "spec/controllers/surveying_controller_spec.rb",
     "spec/controllers/surveying_routing_spec.rb",
     "spec/controllers/surveys_controller_spec.rb",
     "spec/helpers/survey_importer_helper_spec.rb",
     "spec/helpers/surveying_helper_spec.rb",
     "spec/models/answer_spec.rb",
     "spec/models/dependency_condition_spec.rb",
     "spec/models/dependency_spec.rb",
     "spec/models/question_group_spec.rb",
     "spec/models/question_spec.rb",
     "spec/models/response_set_spec.rb",
     "spec/models/response_spec.rb",
     "spec/models/survey_section_spec.rb",
     "spec/models/survey_spec.rb",
     "spec/models/user_spec.rb",
     "spec/spec_helper.rb",
     "spec/views/app/edit.html.erb_spec.rb",
     "spec/views/app/index.html.erb_spec.rb",
     "spec/views/app/new.html.erb_spec.rb",
     "spec/views/app/show.html.erb_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<haml>, [">= 0"])
    else
      s.add_dependency(%q<haml>, [">= 0"])
    end
  else
    s.add_dependency(%q<haml>, [">= 0"])
  end
end
