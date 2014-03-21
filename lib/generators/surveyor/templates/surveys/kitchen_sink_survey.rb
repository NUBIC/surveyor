# encoding: UTF-8
# Question#is_mandatory is now false by default. The default_mandatory option allows you to set
#   is_mandatory for all questions in a survey.
survey "Kitchen Sink survey", :default_mandatory => false do

  section "Basic questions" do
    # A label is a question that accepts no answers
    label "These questions are examples of the basic supported input types"

    # A basic question with radio buttons
    question "What is your favorite color?", :pick => :one
    answer "red"
    answer "blue"
    answer "green"
    answer "yellow"
    answer :other

    # A basic question with checkboxes
    # The "question" and "answer" methods may be abbreviated as "q" and "a".
    # Append a reference identifier (a short string used for dependencies and validations) using the "_" underscore.
    # Question reference identifiers must be unique within a survey.
    # Answer reference identifiers must be unique within a question
    q_2 "Choose the colors you don't like", :pick => :any
    a_1 "red"
    a_2 "blue"
    a_3 "green"
    a_4 "yellow"
    a :omit

    # A dependent question, with conditions and rule to logically join them
    # If the conditions, logically joined into the rule, are met, then the question will be shown.
    q_2a "Please explain why you don't like this color?"
    a_1 "explanation", :text, :help_text => "Please give an explanation for each color you don't like"
    dependency :rule => "A or B or C or D"
    condition_A :q_2, "==", :a_1
    condition_B :q_2, "==", :a_2
    condition_C :q_2, "==", :a_3
    condition_D :q_2, "==", :a_4

    # The count operator checks how many responses exist for the referenced question.
    # It understands conditions of the form: count== count!= count> count< count>= count<=
    q_2b "Please explain why you dislike so many colors?"
    a_1 "explanation", :text
    dependency :rule => "Z"
    condition_Z :q_2, "count>2"

    # When :pick isn't specified, the default is :none (no checkbox or radio button)
    q_montypython3 "What... is your name? (e.g. It is 'Arthur', King of the Britons)"
    a_1 :string

    # Dependency conditions can refer to any value, not just answer_id. An answer_reference still needs to be specified, to know which answer you would like to check
    q_montypython4 "What... is your quest? (e.g. To seek the Holy Grail)"
    a_1 :string
    dependency :rule => "A"
    condition_A :q_montypython3, "==", {:string_value => "It is 'Arthur', King of the Britons", :answer_reference => "1"}

    # http://www.imdb.com/title/tt0071853/quotes
    q_montypython5 "What... is the air-speed velocity of an unladen swallow? (e.g. What do you mean? An African or European swallow?)"
    a_1 :string
    dependency :rule => "A"
    condition_A :q_montypython4, "==", {:string_value => "To seek the Holy Grail", :answer_reference => "1"}

    label "Huh? I-- I don't know that! Auuuuuuuugh!"
    dependency :rule => "A"
    condition_A :q_montypython5, "==", {:string_value => "What do you mean? An African or European swallow?", :answer_reference => "1"}

    q_cooling_1 "How do you cool your home?", :pick => :one
    a_1 "Fans"
    a_2 "Window AC"
    a_3 "Central AC"
    a_4 "Passive"

    # When using !=, also use count>0 if you want to make sure the user responds
    q_cooling_2 "How much does it cost to run your non-passive cooling solutions? (This question hidden until you respond 'How do you cool your home?')"
    dependency :rule => "A and B"
    condition_A :q_cooling_1, "!=", :a_4
    condition_B :q_cooling_1, "count>0"
    a_1 "$", :float

    # Using != alone means the dependent question is shown by default
    label "Please consider passive cooling solutions (This question always shown, unless you respond 'Passive')"
    dependency :rule => "A"
    condition_A :q_cooling_1, "!=", :a_4

    # Surveys, sections, questions, groups, and answers all take the following reference arguments
    # :reference_identifier   # used for parsing references, usually derived from the paper version
    # :data_export_identifier # used for data export
    # :common_namespace       # maping to a common vocabulary - the namespace
    # :common_identifier      # maping to a common vocabulary - the identifier within the namespace
    q "Get me started on an improv sketch", :reference_identifier => "improv_start", :data_export_identifier => "i_s", :common_namespace => "sketch comedy questions", :common_identifier => "get me started"
    a "who", :string
    a "what", :string
    a "where", :string

    # Various types of responses can be accepted, and validated
    q "How many pets do you own?"
    a :integer
    validation :rule => "A"
    condition_A ">=", :integer_value => 0

    # Surveys, sections, questions, groups, and answers also take a custom css class for covenience in custom styling
    q "What is your address?", :custom_class => 'address'
    a :text, :custom_class => 'mapper'
    # validations can use regexp values
    validation :rule => "A"
    condition_A "=~", :regexp => "[0-9a-zA-z\. #]"

    # Questions, groups, and answers take a custom renderer (a partial in the application's views dir)
    # defaults are "/partials/question_group", "/partials/question", "/partials/answer", so the custom renderers should have a different name
    q "Pick your favorite date AND time" #, :custom_renderer => "/partials/custom_question"
    a :datetime

    q_time_lunch "What time do you usually take a lunch break?"
    a_1 :time

    q "When would you like to meet for dinner?"
    a :date

    # Sliders deprecate to select boxes when javascript is off
    # Valid Ruby code may be used to shorten repetitive tasks
    q "Adjust the slider to reflect your level of awesomeness", :pick => :one, :display_type => :slider
    (1..10).to_a.each{|num| a num.to_s}

    q "How much do you like Ruby?", :pick => :one, :display_type => :slider
    ["not at all", "a little", "some", "a lot", "a ton"].each{|level| a level}

    # The "|" pipe is used to place labels before or after the input elements
    q "How much money do you want?"
    a "$|USD", :float

    # Questions may be grouped
    group "How much oil do you use per day?", :display_type => :inline do
      q "Quantity"
      a :float

      q "Unit", :pick => :one, :display_type => :dropdown
      a "Barrels"
      a "Gallons"
      a "Quarts"
    end

    q "Choose your Illinois county", :pick => :one, :display_type => :dropdown
    ["Adams","Alexander","Bond", "Boone",
        "Brown","Bureau","Calhoun","Carroll","Cass",
        "Champaign", "Christian", "Clark","Clay",
        "Clinton", "Coles", "Cook", "Crawford","Cumberland","DeKalb",
        "De Witt","Douglas","DuPage","Edgar", "Edwards",
        "Effingham","Fayette", "Ford","Franklin","Fulton",
        "Gallatin","Greene", "Grundy", "Hamilton","Hancock",
        "Hardin","Henderson","Henry","Iroquois","Jackson",
        "Jasper", "Jefferson","Jersey","Jo Daviess","Johnson",
        "Kane","Kankakee","Kendall","Knox", "La Salle",
        "Lake", "Lawrence", "Lee","Livingston","Logan",
        "Macon","Macoupin","Madison","Marion","Marshall", "Mason",
        "Massac","McDonough","McHenry","McLean","Menard",
        "Mercer","Monroe", "Montgomery","Morgan","Moultrie",
        "Ogle","Peoria","Perry","Piatt","Pike","Pope",
        "Pulaski","Putnam","Randolph","Richland","Rock Island",
        "Saline","Sangamon","Schuyler","Scott","Shelby",
        "St. Clair","Stark", "Stephenson","Tazewell","Union",
        "Vermilion","Wabash","Warren","Washington","Wayne",
        "White","Whiteside","Will","Williamson","Winnebago","Woodford"].each{ |county| a county}

    # When an is_exclusive answer is checked, it unchecks all other options and disables them (using Javascript)
    q "Choose your favorite meats", :display_type => :inline, :pick => :any
    a "Chicken"
    a "Pork"
    a "Beef"
    a "Shellfish"
    a "Fish"
    a "I don't eat meats!!!", :is_exclusive => true

    q "All out of ideas for questions?", :pick => :one, :display_type => :inline
    a "yes"
    a "maybe"
    a "no"
    a "I don't know"

    # Questions may also have input masks with fancy placeholders
    q "What is your phone number?"
    a :string, :input_mask => '(999)999-9999', :input_mask_placeholder => '#'
    
  end

  section "Complicated questions" do

    # Grids are useful for repeated questions with the same set of answers, which are specified before the questions
    grid "Tell us how often do you cover these each day" do
      a "1"
      a "2"
      a "3"
      q "Head", :pick => :one
      q "Knees", :pick => :one
      q "Toes", :pick => :one
    end

    # "grid" is a shortcut for group with :display_type => :grid
    # The answers will be repeated every 10 rows, but long grids aren't recommended as they are generally tedious
    grid "Tell us how you feel today" do
      a "-2"
      a "-1"
      a "0"
      a "1"
      a "2"
      q "down|up" , :pick => :one
      q "sad|happy", :pick => :one
      q "limp|perky", :pick => :one
    end

    grid "For each of the car types checked, what type of options would you prefer?" do
      a "Leather seats"
      a "Shiny rims"
      a "Subwoofer"
      a "Sunroof"
      a "Turbocharger"
      q "SUV", :pick => :any
      q "Sedan", :pick => :any
      q "Coupe", :pick => :any
      q "Convertible", :pick => :any
      q "Minivan", :pick => :any
      q "Crossover", :pick => :any
      q "Wagon", :pick => :any
      q "Other", :pick => :any
    end

    q "Please rank the following foods based on how much you like them"
    a "|pizza", :integer
    a "|salad", :integer
    a "|sushi", :integer
    a "|ice cream", :integer
    a "|breakfast ceral", :integer

    # :other, :string allows someone to specify both the "other" and some other information
    q "Choose your favorite utensils and enter frequency of use (daily, weekly, monthly, etc...)", :pick => :any
    a "spoon", :string
    a "fork", :string
    a "knife", :string
    a :other, :string

    q "What is your birth date?", :pick => :one
    a "I was born on", :date
    a "Refused"

    q "At what time were you born?", :pick => :any
    a "I was born at", :time
    a "This time is approximate"

    q "When would you like to schedule your next appointment?"
    a :datetime

    q_car "Do you own a car?", :pick => :one
    a_y "Yes"
    a_n "No"

    # Repeaters allow multiple responses to a question or set of questions
    repeater "Tell us about the cars you own" do
      dependency :rule => "A"
      condition_A :q_car, "==", :a_y
      q "Make", :pick => :one, :display_type => :dropdown
      a "Toyota"
      a "Ford"
      a "GMChevy"
      a "Ferrari"
      a "Tesla"
      a "Honda"
      a "Other weak brand"
      q "Model"
      a :string
      q "Year"
      a :string
    end

    repeater "Tell us the name and age of your siblings" do
      q "Sibling"
      a "Name", :string
      a "Age|years", :integer
    end

  end
end
