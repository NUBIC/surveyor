# encoding: utf-8
# http://github.com/thoughtbot/factory_girl/tree/master
require 'rubygems'
require 'factory_girl'

FactoryGirl.define do
  
  sequence(:unique_survey_access_code){|n| "simple survey #{UUIDTools::UUID.random_create.to_s}" }
  
  factory :survey do |s|
    s.title           "Simple survey"
    s.description     "A simple survey for testing"
    s.access_code     { FactoryGirl.generate :unique_survey_access_code }
    s.survey_version  0
  end


  factory :survey_translation do |t|
    t.locale "es"
    t.translation %(title: "Un idioma nunca es suficiente"
  survey_sections:
    one:
      title: "Uno"
  questions:
    hello:
      text: "¡Hola!"
    name:
      text: "¿Cómo se llama Usted?"
      answers:
        name:
          help_text: "Mi nombre es...")
  end

  sequence(:survey_section_display_order){|n| n }

  factory :survey_section do |s|
    s.association               :survey # s.survey_id                 {}
    s.title                     {"Demographics"}
    s.description               {"Asking you about your personal data"}
    s.display_order             {FactoryGirl.generate :survey_section_display_order}
    s.reference_identifier      {"demographics"}
    s.data_export_identifier    {"demographics"}
  end

  sequence(:question_display_order){|n| n }

  factory :question do |q|
    q.association             :survey_section  # s.survey_section_id       {}
    # q.question_group_id       {}
    q.text                    "What is your favorite color?"
    q.short_text              "favorite_color"
    q.help_text               "just write it in the box"
    q.pick                    :none
    q.reference_identifier    {|me| "q_#{me.object_id}"}
    # q.data_export_identifier  {}
    # q.common_namespace        {}
    # q.common_identifier       {}
    q.display_order           FactoryGirl.generate(:question_display_order)
    # q.display_type            {} # nil is default
    q.is_mandatory            false
    # q.display_width           {}
    q.correct_answer_id       nil
  end

  factory :question_group do |g|
    g.text                    {"Describe your family"}
    g.help_text               {}
    g.reference_identifier    {|me| "g_#{me.object_id}"}
    g.data_export_identifier  {}
    g.common_namespace        {}
    g.common_identifier       {}
    g.display_type            {}
    g.custom_class            {}
    g.custom_renderer         {}
  end

  sequence(:answer_display_order){|n| n }

  factory :answer do |a|
    a.association               :question  # a.question_id               {}
    a.text                      "My favorite color is clear"
    a.short_text                "clear"
    a.help_text                 "Clear is the absense of color"
    # a.weight
    a.response_class            "string"
    # a.reference_identifier      {}
    # a.data_export_identifier    {}
    # a.common_namespace          {}
    # a.common_identifier         {}
    a.display_order             {FactoryGirl.generate :answer_display_order}
    # a.is_exclusive              {}
    a.display_type              "default"
    # a.display_length            {}
    # a.custom_class              {}
    # a.custom_renderer           {}
  end

  factory :dependency do |d|
    # the dependent question
    d.association       :question # d.question_id       {}
    d.question_group_id {}
    d.rule              {"A"}
  end

  factory :dependency_condition do |d|
    d.association       :dependency # d.dependency_id    {}
    d.rule_key          {"A"}
    # the conditional question
    d.question_id       {}
    d.operator          {"=="}
    d.answer_id         {}
    d.datetime_value    {}
    d.integer_value     {}
    d.float_value       {}
    d.unit              {}
    d.text_value        {}
    d.string_value      {}
    d.response_other    {}
  end

  factory :response_set do |r|
    r.user_id         {}
    r.association     :survey # r.survey_id       {}
    r.access_code     {Surveyor::Common.make_tiny_code}
    r.started_at      {Time.now}
    r.completed_at    {}
  end

  factory :response do |r|
    r.association       :response_set # r.response_set_id   {}
    r.survey_section_id {}
    r.question_id       {}
    r.answer_id         {}
    r.datetime_value    {}
    r.integer_value     {}
    r.float_value       {}
    r.unit              {}
    r.text_value        {}
    r.string_value      {}
    r.response_other    {}
    r.response_group    {}
  end

  factory :validation do |v|
    v.association       :answer # v.answer_id         {}
    v.rule              {"A"}
    v.message           {}
  end

  factory :validation_condition do |v|
    v.association       :validation # v.validation_id     {}
    v.rule_key          {"A"}
    v.question_id       {}
    v.operator          {"=="}
    v.answer_id         {}
    v.datetime_value    {}
    v.integer_value     {}
    v.float_value       {}
    v.unit              {}
    v.text_value        {}
    v.string_value      {}
    v.response_other    {}
    v.regexp            {}
  end

end
