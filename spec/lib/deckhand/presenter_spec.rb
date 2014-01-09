require 'spec_helper'

describe Deckhand::Presenter do

  context '#present' do

    let(:obj) { OpenStruct.new(foo: 1, bar: 2, baz: 3, bonk: 4) }

    before do
      Deckhand.config.stub(:has_model?) {|c| c == OpenStruct }
      Deckhand.config.stub(
        fields_to_show: [:foo, :baz],
        label: ->(_) { "i am #{foo + bar}" }
      )
    end

    it 'returns the expected fields, including label' do
      h = Deckhand::Presenter.new.present(obj)
      expect(h).to eq({_label: "i am 3", foo: 1, baz: 3})
    end

  end
end