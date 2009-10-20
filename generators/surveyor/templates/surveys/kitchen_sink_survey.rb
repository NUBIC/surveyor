survey "&#8220;Kitchen Sink&#8221; survey" do

  section "Basic questions" do
    # A label is a question that accepts no answers
    label "These questions are examples of the basic supported input types"

    # A basic question with radio buttons
    question_1 "What is your favorite color?", :pick => :one
    answer "red"
    answer "blue"
    answer "green"
    answer "yellow"
    answer :other

    # A basic question with checkboxes
    # "question" and "answer" may be abbreviated as "q" and "a"
    q_2 "Choose the colors you don't like", :pick => :any
    a_1 "red"
    a_2 "blue"
    a_3 "green"
    a_4 "yellow"
    a :omit

    # A dependent question, with conditions and rule to logically join them  
    # the question's reference identifier is "2a", and the answer's reference_identifier is "1"
    # question reference identifiers used in conditions need to be unique for the lookups to work
    q_2a "Please explain why you don't like this color?"
    a_1 "explanation", :text
    dependency :rule => "A or B or C or D"
    condition_A :q_2, "==", :a_1
    condition_B :q_2, "==", :a_2
    condition_C :q_2, "==", :a_3
    condition_D :q_2, "==", :a_4

    # When :pick isn't specified, the default is :none (no checkbox or radio button)
    q "What is your name?"
    a :string

    # Surveys, sections, questions, groups, and answers all take the following reference arguments
    # :reference_identifier   # usually from paper
    # :data_export_identifier # data export
    # :common_namespace       # maping to a common vocab
    # :common_identitier      # maping to a common vocab
    q "Get me started on an improv sketch", :reference_identifier => "improv_start", :data_export_identifier => "i_s", :common_namespace => "sketch comedy questions", :common_identifer => "get me started"
    a "who", :string
    a "what", :string
    a "where", :string
    
    # Various types of respones can be accepted
    q "How many pets do you own?"
    a :integer

    q "What is your address?"
    a :text

    q "Pick your favorite date AND time"
    a :datetime
    
    q "What time do you usually take a lunch break?"
    a :time
    
    q "When would you like to meet for dinner?"
    a :date
    
    # Sliders deprecate to select boxes when javascript is off
    # Valid Ruby code may be used to shorted repetitive tasks
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
      a "Quantity", :float

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
    grid "Tell us how you feel today day" do
      a "-2"
      a "-1"
      a "0"
      a "1"
      a "2"
      q "down|up" , :pick => :one
      q "sad|happy", :pick => :one
      q "limp|perky", :pick => :one
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
    
    # Repeaters allow multiple responses to a question or set of questions
    repeater "Tell us about the cars you own" do
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
