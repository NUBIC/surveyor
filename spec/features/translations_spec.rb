# encoding: UTF-8

require 'spec_helper'

describe "translations" do
  it "localizes surveyor prompts" do
    survey_text = %(
      survey "One language is never enough" do
        translations :en => :default
        translations :es => {"title"=>"Un idioma nunca es suficiente", "survey_sections"=>{"one"=>{"title"=>"Uno"}}, "question_groups"=>{"hello"=>{"text"=>"¡Hola!"}}, "questions"=>{"name"=>{"text"=>"¿Cómo se llama Usted?", "answers"=>{"name"=>{"help_text"=>"Mi nombre es..."}}}}}
        translations :he => {"title"=>"ידיעת שפה אחת אינה מספיקה", "survey_sections"=>{"one"=>{"title"=>"אחת"}}, "question_groups"=>{"hello"=>{"text"=>"שלום"}}, "questions"=>{"name"=>{"text"=>"מה שמך?", "answers"=>{"name"=>{"help_text"=>"שמי..."}}}}}
        translations :ko => {"title"=>"한가지 언어로는 충분치 않습니다.", "survey_sections"=>{"one"=>{"title"=>"하나"}}, "question_groups"=>{"hello"=>{"text"=>"안녕하십니까"}}, "questions"=>{"name"=>{"text"=>"성함이 어떻게 되십니까?", "answers"=>{"name"=>{"help_text"=>"제 이름은 ... 입니다"}}}}}
        section_one "One" do
          g_hello "Hello" do
            q_name "What is your name?"
            a_name :string, :help_text => "My name is..."
          end
        end
      end
    )
    Surveyor::Parser.parse(survey_text)
    expect(SurveyTranslation.count).to eq(4)
    locales = %w(en es he ko)
    locales.each{|locale| expect(SurveyTranslation.where(locale: locale).count).to eq(1)}

    start_survey("One language is never enough")
    expect(page).to have_content("One language is never enough")
    locales.each{|locale| expect(page).to have_css("select#locale option[value=#{locale}]")}
    expect(page).to have_content("One")
    expect(page).to have_content("Hello")
    expect(page).to have_content("What is your name?")
    expect(page).to have_content("My name is...")

    start_survey("One language is never enough", locale: "en")
    expect(page).to have_content("One language is never enough")
    locales.each{|locale| expect(page).to have_css("select#locale option[value=#{locale}]")}
    expect(page).to have_content("One")
    expect(page).to have_content("Hello")
    expect(page).to have_content("What is your name?")
    expect(page).to have_content("My name is...")

    start_survey("Un idioma nunca es suficiente", locale: "es")
    expect(page).to have_content("Un idioma nunca es suficiente")
    locales.each{|locale| expect(page).to have_css("select#locale option[value=#{locale}]")}
    expect(page).to have_content("Uno")
    expect(page).to have_content("¡Hola!")
    expect(page).to have_content("¿Cómo se llama Usted?")
    expect(page).to have_content("Mi nombre es...")

    start_survey("ידיעת שפה אחת אינה מספיקה", locale: "he")
    expect(page).to have_content("ידיעת שפה אחת אינה מספיקה")
    locales.each{|locale| expect(page).to have_css("select#locale option[value=#{locale}]")}
    expect(page).to have_content("אחת")
    expect(page).to have_content("שלום")
    expect(page).to have_content("מה שמך?")
    expect(page).to have_content("שמי...")

    start_survey("한가지 언어로는 충분치 않습니다.", locale: "ko")
    expect(page).to have_content("한가지 언어로는 충분치 않습니다.")
    locales.each{|locale| expect(page).to have_css("select#locale option[value=#{locale}]")}
    expect(page).to have_content("하나")
    expect(page).to have_content("안녕하십니까")
    expect(page).to have_content("성함이 어떻게 되십니까?")
    expect(page).to have_content("제 이름은 ... 입니다")

    start_survey("One language is never enough")
    expect(page).to have_content("One language is never enough")
    locales.each{|locale| expect(page).to have_css("select#locale option[value=#{locale}]")}
    expect(page).to have_content("One")
    expect(page).to have_content("Hello")
    expect(page).to have_content("What is your name?")
    expect(page).to have_content("My name is...")
  end
  it "switches locales", js: true do
    survey_text = %(
      survey "One language is never enough" do
        translations :en => :default
        translations :es => {"title"=>"Un idioma nunca es suficiente", "survey_sections"=>{"one"=>{"title"=>"Uno"}, "two"=>{"title"=>"Dos"}}, "question_groups"=>{"hello"=>{"text"=>"¡Hola!"}}, "questions"=>{"name"=>{"text"=>"¿Cómo se llama Usted?", "answers"=>{"name"=>{"help_text"=>"Mi nombre es..."}}}, "color"=>{"text"=>"¿Cuál es tu color favorito?"}}}
        translations :he => {"title"=>"ידיעת שפה אחת אינה מספיקה", "survey_sections"=>{"one"=>{"title"=>"אחת"}, "two"=>{"title"=>"שנים"}}, "question_groups"=>{"hello"=>{"text"=>"שלום"}}, "questions"=>{"name"=>{"text"=>"מה שמך?", "answers"=>{"name"=>{"help_text"=>"שמי..."}}}, "color"=>{"text"=>"מהו הצבע האהוב עליך?"}}}

        section_one "One" do
          g_hello "Hello" do
            q_name "What is your name?"
            a_name :string, :help_text => "My name is..."
          end
        end

        section_two "Two" do
          q_color "What is your favorite color?"
          a_name :string
        end
      end
    )
    Surveyor::Parser.parse(survey_text)
    locales = %w(en es he)
    start_survey("One language is never enough", locale: "en")
    expect(page).to have_content("One language is never enough")
    expect(page).to have_content("What is your name?")
    expect(page).to have_content("Language")
    locales.each{|locale| expect(page).to have_css("select#locale option[value=#{locale}]")}
    select("es", from: "locale")
    expect(page).to have_content("Un idioma nunca es suficiente")
    expect(page).to have_content("¿Cómo se llama Usted?")
    click_button "Dos"
    expect(page).to have_content("¿Cuál es tu color favorito?")
    select("he", from: "locale")
    expect(page).to have_content("מהו הצבע האהוב עליך?")
  end
  context "without translations" do
    include_context "favorites"
    it "hides the locale menu" do
      start_survey("Favorites")
      expect('page').to_not have_css("select#locale")
    end
  end
end