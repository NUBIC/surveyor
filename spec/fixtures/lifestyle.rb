survey "Lifestyle" do
  section "Smoking" do
    q_copd_sh_1 "Have you ever smoked cigarettes?", :pick => :one, :help_text => "NO means less than 20 packs of cigarettes or 12 oz. of tobacco in a lifetime or less than 1 cigarette a day for 1 year."
    a_1 "Yes"
    a_2 "No"

    q_copd_sh_1b "Do you currently smoke cigarettes?", :pick => :one, :help_text => "as of 1 month ago"
    a_current_as_of_one_month "Yes"
    a_quit "No"
    dependency :rule => "B"
    condition_B :question_copd_sh_1, "==", :answer_1

    q_copd_sh_1ba "How old were you when you stopped?"
    a "Years", :integer
    dependency :rule => "C"
    condition_C :q_copd_sh_1b, "==", :a_quit

    q_copd_sh_1bb "How many cigarettes do you smoke per day now?"
    a_2 "integer"
    dependency :rule => "D"
    condition_D :q_copd_sh_1b, "==", :a_current_as_of_one_month
  end
  section "Pets" do
    q_pets "How many pets do you own?"
    a_number :integer
    validation :rule => "P"
    condition_P ">=", :integer_value => 0

    group_one_pet "One pet" do
      dependency :rule => "Q"
      condition_Q :q_pets, "==", {:integer_value => 1, :answer_reference => "number"}

      q_favorite_pet "What is you pet's name?"
      a_name :string

      label_very_creative "Very creative!"
      dependency :rule => "R"
      condition_R :q_favorite_pet, "==", {:string_value => "fido", :answer_reference => "name"}
    end

    q "What is the address of your vet?", :custom_class => 'address'
    a :text, :custom_class => 'mapper'
    validation :rule => "AC"
    vcondition_AC "=~", :regexp => /[0-9a-zA-z\. #]/.to_s

    q_dream_pet "What is your dream pet?", :pick => :any
    a_1 "lion"
    a_2 "tiger"
    a_3 "bear"

    label_oh_my "Oh my!"
    dependency :rule => "S"
    condition_S :q_dream_pet, "count>2"
  end
end