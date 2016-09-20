survey "Skip logic" do
  section_first "First" do
    q_name "What is your name?"
    a_name :string
    validation :rule => "A"
    condition_A "!=", :string_value => ""

    # check complex rules
    sl :section_easy, :rule => "A or B"
    condition_A :q_name, "==", { :answer_reference => "name", :string_value => "King Arthur" }
    condition_B :q_name, "==", { :answer_reference => "name", :string_value => "Lancelot" }

    # check target section with no prefix
    sl :hard, :rule => "C"
    condition_C :q_name, "==", { :answer_reference => "name", :string_value => "Sir Robin" }
  end

  section_easy "Easy" do
    q_color "What is your favorite color?"
    a_color :string
    dependency :rule => "A"
    condition_A :q_name, "!=", { :answer_reference => "name", :string_value => "" }

    # check short circuit finishing (with a potential name conflict)
    sl :end, :rule => "F"
    condition_F :q_color, "!=", { :answer_reference => "color", :string_value => "" }
  end

  section_hard "Hard" do
    q_swallow "What is the air speed velocity of an unladen swallow?", :pick => :one
    a_question "African or European?"
    a_dont_know "I don't know that..."

    # check s_ prefix on target section
    sl :s_end, :rule => "D", :execute_order => 2
    slcondition_D :q_swallow, "==", :a_question

    # check full prefix on target section
    sl :survey_section_end, :rule => "E", :execute_order => 1
    slc_E :q_swallow, "==", :a_dont_know
  end

  section_end "End" do
    label "You may pass"
    dependency :rule => "A or B"
    condition_A :q_color, "!=", { :answer_reference => "color", :string_value => "" }
    condition_B :q_swallow, "==", :a_question

    label "You are dead"
    dependency :rule => "A"
    condition_A :q_swallow, "==", :a_dont_know
  end
end