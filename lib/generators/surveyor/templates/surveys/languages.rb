# encoding: UTF-8
survey "One language is never enough" do
  translations :es => "translations/languages.es.yml", :he => "translations/languages.he.yml", :ko => "translations/languages.ko.yml"
  section_one "One" do
    g_hello "Hello" do
	    q_name "What is your name?"
	    a_name :string, :help_text => "My name is..."
	  end
  end
end