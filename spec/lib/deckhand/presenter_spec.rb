require 'spec_helper'

describe Deckhand::Presenter do
  context '#present' do
    let(:obj) { OpenStruct.new(foo: 1, bar: 2, baz: 3, bonk: 4) }

    before do
      Deckhand.configure do
        model OpenStruct do
          show :foo, :baz, class_name: :dummy
          label { "i am #{foo + bar}" }
        end
      end
      Deckhand.config.run
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
      Deckhand.configure do
        model Foo do
          show :bars, class_name: :foo
        end

        model Bar do
          show :foos, class_name: :bar
        end
      end
      Deckhand.config.run

      foo.bars = [bar]
      bar.foos = [foo]
    end

    it 'does not cause infinite loops' do
      h = Deckhand::Presenter.new.present(foo)
      expect(h).to eq({
        _model: 'Foo',
        _label: 'foo',
        id: 'foo',
        bars: [
          {
            _model: 'Bar',
            _label: 'bar',
            id: 'bar'
          }
        ]
      })
    end
  end

  context 'with tables' do
    before do
      Deckhand.configure do
        model Foo do
          show :thing, class_name: :foo
          show :bars, table: [:bar], class_name: 'Bar'
        end

        model Bar do
          show :baz, :bonk, :foos
        end

        model Baz do
          show :foo, class_name: 'Foo'
        end
      end
      Deckhand.config.run
    end

    let(:foo) { Foo.new(thing: 'thing', bars: [Bar.new(bar: 1, baz: 2, bonk: 3)]) }
    let(:baz) { Baz.new(foo: foo) }

    it 'overrides the default fields to show' do
      h = Deckhand::Presenter.new.present(foo)
      h.should eq({
        _model: 'Foo',
        _label: nil,
        id: nil,
        thing: 'thing',
        bars: [
          {
            _model: 'Bar',
            _label: nil,
            id: nil,
            bar: 1
          }
        ]
      })
    end

    it "doesn't include non-core fields when nested" do
      h = Deckhand::Presenter.new.present(baz)
      h.should eq({
        _model: 'Baz',
        _label: nil,
        id: nil,
        foo: {
          _model: 'Foo',
          _label: nil,
          id: nil
        }
      })
    end
  end

  context 'with delegation' do
    before do
      Deckhand.configure do
        model Foo do
          show :bar, delegate: :bonk, class_name: :foo
        end

        model Bar do
          show :baz, class_name: :bar
        end
      end
      Deckhand.config.run
    end

    let(:foo) { Foo.new bar: Bar.new(bonk: 5) }

    it 'includes delegate fields when nested' do
      h = Deckhand::Presenter.new.present(foo)
      h.should eq({
        _model: 'Foo',
        _label: nil,
        id: nil,
        bar: {
          _model: 'Bar',
          _label: nil,
          id: nil,
          bonk: 5
        }
      })
    end
  end

  context 'with lazy-loaded tables' do
    before do
      Deckhand.configure do
        model Foo do
          show :bars, table: [:quuz], lazy_load: true, class_name: 'Bar'
        end

        model Bar do
          show :quuz, :quux
        end
      end
      Deckhand.config.run
    end

    let(:bar) { Bar.new quuz: 1, quux: 2 }
    let(:foo) { Foo.new bars: [bar] }

    it "uses an empty array as a placeholder for the relation" do
      h = Deckhand::Presenter.new.present(foo)
      expect(h).to eq({
        _model: 'Foo',
        id: nil,
        _label: nil,
        bars: []
      })
    end

    it 'loads the relation when eager_load is set' do
      h = Deckhand::Presenter.new(eager_load: true).present(foo)
      expect(h).to eq({
        _model: 'Foo',
        id: nil,
        _label: nil,
        bars: [{
          _model: 'Bar',
          id: nil,
          _label: nil,
          quuz: 1
        }]
      })
    end
  end

  context 'with choices' do
    shared_examples :choices_field do |field, choices|
      it 'appends a field with choices' do
        h = Deckhand::Presenter.new.present(obj)
        expect(h[field]).to eq(choices)
      end
    end

    let(:obj) { OpenStruct.new(cool_factor: 1) }

    def configureDeckhand(configured_choices)
      Deckhand.configure do
        model OpenStruct do
          show :cool_factor, class_name: :dummy, choices: configured_choices
          label { "dummy" }
        end
      end
    end

    before(:each) do
      configureDeckhand(configured_choices)
      Deckhand.config.run
    end

    context 'as plain array' do
      let(:configured_choices) { [1, 2] }

      it_behaves_like :choices_field, :cool_factor_choices, [{key: 1, value: 1}, {key: 2, value: 2}]
    end

    context 'as array with one element' do
      let(:configured_choices) { [[1], [2]] }

      it_behaves_like :choices_field, :cool_factor_choices, [{key: 1, value: 1}, {key: 2, value: 2}]
    end

    context 'as rails options like array' do
      let(:configured_choices) { [['way cool', 1], ['cooler master', 2]] }

      it_behaves_like :choices_field, :cool_factor_choices, [{key: 1, value: 'way cool'}, {key: 2, value: 'cooler master'}]
    end

    context 'as array with more elements' do
      let(:configured_choices) { [['way cool', 1, :ignore], ['cooler master', 2, :ignore]] }

      it_behaves_like :choices_field, :cool_factor_choices, [{key: 1, value: 'way cool'}, {key: 2, value: 'cooler master'}]
    end

    context 'as hash with matching keys' do
      let(:configured_choices) { [{key: 1, value: 'way cool'}, {key: 2, value: 'cooler master'}] }

      it_behaves_like :choices_field, :cool_factor_choices, [{key: 1, value: 'way cool'}, {key: 2, value: 'cooler master'}]
    end

    context 'as hash with non matching keys' do
      let(:configured_choices) { [{id: 1, name: 'way cool'}, {id: 2, name: 'cooler master'}] }

      it_behaves_like :choices_field, :cool_factor_choices, [{key: 1, value: 'way cool'}, {key: 2, value: 'cooler master'}]
    end

    context 'as method' do
      let(:obj) { OpenStruct.new(cool_factor: 1, cool_factor_options: [['way cool', 1], ['cooler master', 2]]) }
      let(:configured_choices) { :cool_factor_options }

      it_behaves_like :choices_field, :cool_factor_choices, [{key: 1, value: 'way cool'}, {key: 2, value: 'cooler master'}]
    end
  end
end