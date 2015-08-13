survey "Favorites" do
  section_colors "Colors" do
    label "These questions are examples of the basic supported input types"

    question "What is your favorite color?", {reference_identifier: "1", pick: :one}
    answer "red",   {reference_identifier: "r", data_export_identifier: "1"}
    answer "blue",  {reference_identifier: "b", data_export_identifier: "2"}
    answer "green", {reference_identifier: "g", data_export_identifier: "3"}
    answer :other

    q_2b "Choose the colors you don't like", :pick => :any
    a_1 "orange", :display_order => 1
    a_2 "purple", :display_order => 2
    a_3 "brown", :display_order => 0
    a :omit

    q_fire_engine "What is the best color for a fire engine?"
    a_color "Color", :string
  end
  section_numbers "Numbers" do
  end
end
