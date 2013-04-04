# encoding: UTF-8
survey "One language is never enough" do
  translations :en =>:default, :es => "translations/languages.es.yml", :he => "translations/languages.he.yml", :ko => "translations/languages.ko.yml"
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
