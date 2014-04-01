survey "Everything" do
  section "Basic" do
    question "What is your favorite color?", {reference_identifier: "1", pick: :one}
    answer "red",   {reference_identifier: "r", data_export_identifier: "1"}
    answer "blue",  {reference_identifier: "b", data_export_identifier: "2"}
    answer "green", {reference_identifier: "g", data_export_identifier: "3"}
    answer :other

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
  end
  section "Groups" do
  end
  section "Dependencies" do
  end
  section "Special" do
  end
end