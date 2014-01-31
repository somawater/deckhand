require 'spec_helper'

describe Deckhand::Presenter do

  context '#present' do

    let(:obj) { OpenStruct.new(foo: 1, bar: 2, baz: 3, bonk: 4) }

    before do
      Deckhand.configure do
        model OpenStruct do
          show :foo, :baz
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
          show :bars
        end

        model Bar do
          show :foos
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
          show :thing
          show :bars, table: [:bar]
        end

        model Bar do
          show :baz, :bonk, :foos
        end

        model Baz do
          show :foo
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
          show :bar, delegate: :bonk
        end

        model Bar do
          show :baz
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
          show :bars, table: [:quuz], lazy_load: true
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

end