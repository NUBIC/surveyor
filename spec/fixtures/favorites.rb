survey "Favories" do
  section_colors "Colors" do
    label "These questions are examples of the basic supported input types"

    question "What is your favorite color?", {reference_identifier: "1", pick: :one}
    answer "red",   {reference_identifier: "r"}
    answer "blue",  {reference_identifier: "b"}
    answer "green", {reference_identifier: "g"}
    answer :other

    q_2b "Choose the colors you don't like", :pick => :any
    a_1 "orange", :display_order => 1
    a_2 "purple", :display_order => 2
    a_3 "brown", :display_order => 0
    a :omit
  end
  section_numbers "Numbers" do
  end
end
