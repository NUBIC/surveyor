survey "&#8220;Kitchen Sink&#8221; survey" do

  section "Basic questions" do

    # exclusive
    # name people you live with (choose all that apply)
    # husband, friend, partner, siblings, other, alone, choose not to answer
    # alone unchecks/erases, and disables all the others
    # omit (choose not to answer) is exclusive as well

    # a label is a question that accepts no answers
    # reference_identifier => label
    label "These questions are examples of the basic supported input types"


    # a basic question,
    # reference_identifier => 1
    question_1 "What is your favorite color?", :pick => :one
    answer "red"
    answer "blue"
    answer "green"
    answer "yellow"
    answer :other # :other is a custom answer symbol type, it has associated pre-sets with it

    question_2 "Choose the colors you don't like", :pick => :any
    answer_1 "red"
    answer_2 "blue"
    answer_3 "green"
    answer_4 "yellow"
    answer :omit
    
    q_2a "Please explain why you don't like this color?"
    a_1 "explanation", :text
    dependency :rule => "A or B or C or D"
    condition_A :q_2, "==", :a_1
    condition_B :q_2, "==", :a_2
    condition_C :q_2, "==", :a_3
    condition_D :q_2, "==", :a_4

    # question definitions can be abreviated as shown below
    # questions and answers don't need to have numbers. Only if they are referenced in a dependency condition
    q "What is your name?"
    a :string

    q "Give your response"
    a "who", :string
    a "what", :string
    a "where", :string

    q "How many pets do you own?" 
    a :integer

    q "What is your address?" 
    a :text
    # 
    # q "Pick your favorite date"
    # a :date
    # 
    # q "Pick your favorite time"
    # a :time

    q "Pick your favorite date AND time"
    a :datetime
    
    q "What time would you like to meet?"
    a :time
    
    q "What date would you like to meet?"
    a :date

    q "Adjust the slider to reflect your level of awesomeness", :pick => :one, :display_type => :slider
    (1..10).to_a.each{ |num| a num.to_s}

    q "How much do you like Ruby?", :pick => :one, :display_type => :slider
    ["not at all", "a little", "some", "a lot", "a ton"].each{|level| a level}

    # range "When did you start working at NUBIC?", :range_type => :date do
    #      q "From"
    #      a :date
    #      
    #      q "To"
    #      a :date
    #    end
    #    
    #    range "What times are you awake?", :range_type => :integer do
    #      q "From"
    #      a :integer
    #      
    #      q "To"
    #      a :integer
    #    end
    
    q "How much money do you want?"
    a "$|USD", :float, :unit => "F"  

    group "How much oil do yo use per day?" do
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

    grid "Tell us how often do you cover these each day" do
      a "1"
      a "2"
      a "3"
      q "Head", :pick => :one
      q "Knees", :pick => :one
      q "Toes", :pick => :one
    end

    grid "Tell us how you feel today day" do
      a "-2"
      a "-1"
      a "0"
      a "1"
      a "2"
      a :omit
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
    

    q "Choose your favorite utensils and enter frequency of use (daily, weekly, monthly, etc...)", :pick => :any
    a "spoon", :string
    a "fork", :string
    a "knife", :string
    a :other, :string

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
      a "Age", :integer, :unit => "years"
    end

  end
end
