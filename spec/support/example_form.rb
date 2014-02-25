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

  multiple :positions do
    input :left_side
    input :right_side
    input :intensity, type: Integer
  end

  group :album, label: 'Album > Songs' do
    input :title

    multiple :songs, label: 'Songs:' do
      input :title
    end
  end

  def forty_one
    41
  end

  def forty_two
    42
  end
end
