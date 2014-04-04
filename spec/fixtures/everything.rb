survey "Everything" do
  section "Basic" do
    question "What is your favorite color?", {reference_identifier: "1", pick: :one}
    answer "red",   {reference_identifier: "r", data_export_identifier: "1"}
    answer "blue",  {reference_identifier: "b", data_export_identifier: "2"}
    answer "green", {reference_identifier: "g", data_export_identifier: "3"}
    answer_other :other, :string

    q_2b "Choose the colors you don't like", pick: :any
    a_1 "orange", :display_order => 1
    a_2 "purple", :display_order => 2
    a_3 "brown", :display_order => 0
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

    q_color_run_date "When is the next color run?"
    a_date "On", :date

    q_color_run_time "What time does it start?"
    a_time "At", :time

    q_hair_appointment "When is your next hair color appointment?"
    a_datetime "At", :datetime

    q_color_poem "Please compose a poem about a color"
    a_poem_text "Poem", :text
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
  end
  section "Dependencies" do
  end
  section "Special" do
  end
end