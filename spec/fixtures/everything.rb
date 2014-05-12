survey "Everything" do
  section "Basic" do
    question "What is your favorite color?", {reference_identifier: "1", pick: :one}
    answer "red",   {reference_identifier: "r", data_export_identifier: "1"}
    answer "blue",  {reference_identifier: "b", data_export_identifier: "2"}
    answer "green", {reference_identifier: "g", data_export_identifier: "3"}
    answer_other :other, :string

    q_2b "Choose the colors you don't like", pick: :any
    a_1 "orange", display_order: 1
    a_2 "purple", display_order: 2
    a_3 "brown", display_order: 0
    a :omit

    q_3 "What color is the sky right now?", pick: :one, display_type: :dropdown
    a_sb "sky blue"
    a_cw "cloud white"
    a_nb "night black"
    a_sr "sunset red"

    q_fire_engine "What is the best color for a fire engine?"
    a_color "Color", :string

    q_last_room "What was the last room you painted, and what color?", pick: :one
    a_kitchen "kitchen", :string
    a_bedroom "bedroom", :string
    a_bathroom "bathroom", :string
    a_other "other", :text

    q_all_rooms "What rooms have you painted, and what color?", pick: :any
    a_kitchen "kitchen", :string
    a_bedroom "bedroom", :string
    a_bathroom "bathroom", :string
    a_other "other", :text

    q_color_run_date "When is the next color run?"
    a_date "On", :date

    q_color_run_time "What time does it start?"
    a_time "At", :time

    q_hair_appointment "When is your next hair color appointment?"
    a_datetime "At", :datetime

    q_color_poem "Please compose a poem about a color"
    a_poem_text "Poem", :text

    q_birth_date "What is your birth date?", pick: :one
    a_date "I was born on", :date
    a_refused "Refused"

    q_birth_time "At what time were you born?", pick: :any
    a_time "I was born at", :time
    a_approx "This time is approximate"
  end
  section "Groups" do
    grid_events "How interested are you in the following?" do
      a "indifferent"
      a "neutral"
      a "interested"
      q "births" , pick: :one
      q "weddings", pick: :one
      q "funerals", pick: :one
    end
    repeater_family "Tell us about your family"  do
      q_relation "Relation", pick: :one, display_type: :dropdown
      a "Parent"
      a "Sibling"
      a "Child"
      q_name "Name"
      a "Name", :string
      q_quality "Quality of your relationship"
      a "Quality of your relationship", :string
    end
    group_drop_it "Drop it like it's hot" do
      label "Like Snoop Dogg said"
      q_what_drop "What to drop", pick: :one, display_type: :dropdown
      a_it "It"
      a_potato "Hot potato"
      a_and_10 "And give me 10"
    end
  end
  section "Dependencies" do
    group "Greetings" do
      q_anybody "Anybody there?", :pick => :one
      a_yes "Yes"
      a_no "No"

      q_who "Who are you?"
      dependency :rule => "A"
      condition_A :q_anybody, "==", :a_yes
      a :string

      q_weird "Weird.. Must be talking to myself..", :pick => :one
      dependency :rule => "A"
      condition_A :q_anybody, "==", :a_no
      a "Maybe"
      a "Huh?"
    end
    group_anybody_no "No?" do
      dependency :rule => "A"
      condition_A :q_anybody, "==", :a_no

      q_who_talking "Who is talking?", :pick => :one
      a_you_are "You are"
      a_you_nuts "Are you nuts?"
    end
    label_feels_like_it "It feels like it"
    dependency :rule => "A"
    condition_A :q_who_talking, "==", :a_you_nuts

    q_cooling_1 "How do you cool your home?", :pick => :one
    a_1 "Fans"
    a_2 "Window AC"
    a_3 "Central AC"
    a_4 "Passive"

    q_cooling_2 "How much does it cost to run your non-passive cooling solutions?"
    dependency :rule => "A"
    condition_A :q_cooling_1, "!=", :a_4
    a_1 "$", :float

    q_heating_1 "How do you heat your home?", :pick => :any
    a_1 "Forced air"
    a_2 "Radiators"
    a_3 "Oven"
    a_4 "Passive"

    q_heating_2 "How much does it cost to run your non-passive heating solutions?"
    dependency :rule => "A and B"
    condition_A :q_heating_1, "!=", :a_4
    condition_B :q_heating_1, "count>0"
    a_1 "$", :float

    q_heating_3 "How much do you spend on air filters each year?"
    dependency :rule => "A"
    condition_A :q_heating_1, "==", :a_1
    a_1 "$", :float

    q_counts "How many times do you count a day", :pick => :any
    a_1 "Once for me"
    a_2 "Once for you"
    a_3 "Once for everyone"

    label_counts_good "Good!"
    dependency :rule => "A"
    condition_A :q_counts, "count==1"

    label_counts_twice "Twice as good!"
    dependency :rule => "A"
    condition_A :q_counts, "count==2"

    label_thanks_counting "Thanks for counting!"
    dependency :rule => "A or B or C"
    condition_A :q_counts, "==", :a_1
    condition_B :q_counts, "==", :a_2
    condition_C :q_counts, "==", :a_3

    label_yay_everyone "Yay for everyone!"
    dependency :rule => "A"
    condition_A :q_counts, "count>2"
  end
  section "Special" do
    group_mustache_regarding "Regarding {{name}}", help_text: "Answer all you know about {{name}}" do
      q_mustache_where "Where does {{name}} live?", pick: :one, help_text: "If you don't know where {{name}} lives, skip the question"
      a_north_pole "{{name}} lives on North Pole"
      a_south_pole "{{name}} lives on South Pole"
      a_fake "{{name}} doesn't exist"
    end
    label "Now think about {{thing}}", help_text: "Yes, {{thing}}"

    q_home_phone "What is your home phone number?"
    a_hm_phone "phone", :string, input_mask: '(999)999-9999', input_mask_placeholder: '#'

    q_cell_phone "What is your cell phone number?"
    a_cl_phone "phone", :string, input_mask: '(999)999-9999'

    q_favorite_letters "What are your favorite letters?"
    a_fav_letters 'letters', :string, input_mask: 'aaaaaaaaa'

    q_count_name "What is your name?", display_type: :hidden
    a_name :string, help_text: "(e.g. Count Von Count)"

    group_count_friends "Friends", display_type: :hidden do
      q_count_who_friends "Who are your friends?"
      a_friends :string
    end

    q_count_numbers "What is your favorite number?", pick: :one, custom_class: "hidden"
    a_one "One"
    a_two "Two"
    a_three "Three!"

    q_heat2 "Are there any other types of heat you use regularly during the heating season to heat your home? ", pick: :any
    a_1 "Electric"
    a_2 "Gas - propane or LP"
    a_3 "Oil"
    a_4 "Wood"
    a_5 "Kerosene or diesel"
    a_6 "Coal or coke"
    a_7 "Solar energy"
    a_8 "Heat pump"
    a_9 "No other heating source", is_exclusive: true
    a_neg_5 "Other"
    a_neg_1 "Refused", is_exclusive: true
    a_neg_2 "Don't know", is_exclusive: true

    question_favorite_food "What is your favorite food?", help_text: "just say beef"
    answer_food "food", :string, :default_value => "beef"

    q_which_way "Which way?"
    a_next "/assets/surveyor/next.gif", :display_type => "image"
    a_prev "/assets/surveyor/prev.gif", :display_type => "image"
  end
end