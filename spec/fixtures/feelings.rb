# frozen_string_literal: true

survey 'Feelings' do
  section_daily 'Current' do
    grid_today 'Tell us how you feel today' do
      a_minus_2 '-2'
      a_minus_1 '-1'
      a_0 '0'
      a_1 '1'
      a_1 '2'
      q_anxious_calm 'anxious|calm', pick: :one
      q_sad_happy 'sad|happy', pick: :one
      q_tired_energetic 'tired|energetic', pick: :one
    end
    grid_events 'How interested are you in the following?' do
      a 'indifferent'
      a 'neutral'
      a 'interested'
      q 'births', pick: :one
      q 'weddings', pick: :one
      q 'funerals', pick: :one
    end
    repeater_family 'Tell us about your family' do
      q 'Relation', pick: :one, display_type: :dropdown
      a 'Parent'
      a 'Sibling'
      a 'Child'
      q 'Name'
      a :string
      q 'Quality of your relationship'
      a :string
    end
    q_description 'Tell us which of the following describe you, and why', pick: :any
    a 'joyful', :string
    a 'content', :string
    a 'anxious', :string
    a 'upset', :string
    a :other, :string
  end
end
