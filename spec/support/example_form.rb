class ExampleForm < Deckhand::Form
  object_name :thing

  input :foo, type: Integer
  input :bar, type: Float
  input :baz, type: Integer, default: :forty_two
  input :bonk, default: :forty_one
  input :here, type: :boolean, default: true
  input :there, type: :boolean, default: false
  input :nowhere
  input :with_help, help: 'Whatever'
  input :marital_status, choices: :marital_status_enum

  multiple :positions do
    input :left_side
    input :right_side
    input :intensity, type: Integer, default: 100
    input :preference, choices: :position_preference_enum
  end

  group :album, label: 'Album > Songs' do
    input :title, default: 'YMCA'
    input :play_speed, choices: [['LP', 33], ['SP', 45]]

    multiple :songs, label: 'Songs:' do
      input :title
      input :remix, default: true
    end
  end

  def forty_one
    41
  end

  def forty_two
    42
  end

  def marital_status_enum
    [['Single', 's'], ['Married', 'm']]
  end

  def position_preference_enum
    [['Left', 1], ['Right', 2]]
  end
end
