# encoding: UTF-8
Feature: Internationalization
  As survey taker
  I want to see surveys in my own language
  So that I understand what they're asking

  Scenario:
  Given I parse
    """
    survey "One language is never enough" do
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
    """
  Then there should be 3 translations with
    | locale |
    | es     |
    | he     |
    | ko     |
  When I start the survey
  Then I should see "One language is never enough"
    And I should see "One"
    And I should see "Hello"
    And I should see "What is your name?"
    And I should see "My name is..."
  When I start the survey in "es"
  Then I should see "Un idioma nunca es suficiente"
    And I should see "Uno"
    And I should see "¡Hola!"
    And I should see "¿Cómo se llama Usted?"
    And I should see "Mi nombre es..."
  When I start the survey in "he"
  Then I should see "ידיעת שפה אחת אינה מספיקה"
    And I should see "אחת"
    And I should see "שלום"
    And I should see "מה שמך?"
    And I should see "שמי..."
  When I start the survey in "ko"
  Then I should see "한가지 언어로는 충분치 않습니다."
    And I should see "하나"
    And I should see "안녕하십니까"
    And I should see "성함이 어떻게 되십니까?"
    And I should see "제 이름은 ... 입니다"
  When I start the survey
  Then I should see "One language is never enough"
    And I should see "One"
    And I should see "Hello"
    And I should see "What is your name?"
    And I should see "My name is..."

