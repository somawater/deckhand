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

    it 'returns the expected fields, including label and model' do
      h = Deckhand::Presenter.new.present(obj)
      expect(h).to eq({_model: 'OpenStruct', _label: "i am 3", id: nil, foo: 1, baz: 3})
    end

  end

  context 'with cyclical relations' do
    let(:foo) { Foo.new(id: 'foo') }
    let(:bar) { Bar.new(id: 'bar') }

    before do
      Foo = Class.new OpenStruct
      Bar = Class.new OpenStruct
      Deckhand.configure do
        model Foo do
          show_only :bars
        end

        model Bar do
          show_only :foos
        end
      end
      Deckhand.config.load_initializer_block

      foo.bars = [bar]
      bar.foos = [foo]
    end

    it 'prevents infinite loops' do
      h = Deckhand::Presenter.new.present(foo)
      expect(h).to eq({
        _model: 'Foo',
        _label: 'foo',
        id: 'foo',
        bars: [
          {
            _model: 'Bar',
            _label: 'bar',
            id: 'bar',
            foos: [
              {
                _model: 'Foo',
                _label: 'foo',
                id: 'foo'
              }
            ]
          }
        ]
      })
    end

  end

end