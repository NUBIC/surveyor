# encoding: UTF-8
Feature: Internationalization
  As survey taker
  I want to see surveys in my own language
  So that I understand what they're asking

  Scenario:
  Given I parse
    """
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
    """
  Then there should be 4 translations with
    | locale |
    | en     |
    | es     |
    | he     |
    | ko     |
  When I start the survey
  Then I should see "One language is never enough"
    And a dropdown should exist with the options "en, es, he, ko"
    And I should see "One"
    And I should see "Hello"
    And I should see "What is your name?"
    And I should see "My name is..."
  When I start the survey in "en"
  Then I should see "One language is never enough"
    And a dropdown should exist with the options "en, es, he, ko"
    And I should see "One"
    And I should see "Hello"
    And I should see "What is your name?"
    And I should see "My name is..."
  When I start the survey in "es"
  Then I should see "Un idioma nunca es suficiente"
    And a dropdown should exist with the options "en, es, he, ko"
    And I should see "Uno"
    And I should see "¡Hola!"
    And I should see "¿Cómo se llama Usted?"
    And I should see "Mi nombre es..."
  When I start the survey in "he"
  Then I should see "ידיעת שפה אחת אינה מספיקה"
    And a dropdown should exist with the options "en, es, he, ko"
    And I should see "אחת"
    And I should see "שלום"
    And I should see "מה שמך?"
    And I should see "שמי..."
  When I start the survey in "ko"
  Then I should see "한가지 언어로는 충분치 않습니다."
    And a dropdown should exist with the options "en, es, he, ko"
    And I should see "하나"
    And I should see "안녕하십니까"
    And I should see "성함이 어떻게 되십니까?"
    And I should see "제 이름은 ... 입니다"
  When I start the survey
  Then I should see "One language is never enough"
    And a dropdown should exist with the options "en, es, he, ko"
    And I should see "One"
    And I should see "Hello"
    And I should see "What is your name?"
    And I should see "My name is..."


  Scenario:
  Given I parse
    """
    survey "Favorites" do
      section "Foods" do
        question_1 "What is the best meat?", :pick => :one, :correct => "oink"
        a_oink "bacon"
        a_tweet "chicken"
        a_moo "beef"
      end
    end
    """
   When I start the survey
   Then I should not see "Language"

  @javascript
  Scenario:
  Given I parse
    """
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
    """
  When I start the survey in "en"
  Then I should see "One language is never enough"
    And I should see "What is your name?"
    And I should see "Language"
    And a dropdown should exist with the options "en, es, he"
  When I change the locale to "es"
  Then I should see "Un idioma nunca es suficiente"
    And I should see "¿Cómo se llama Usted?"
  When I press "Dos"
  Then I should see "¿Cuál es tu color favorito?"
  When I change the locale to "he"
  Then I should see "מהו הצבע האהוב עליך?"
