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

    it "doesn't include table fields when nested" do
      h = Deckhand::Presenter.new.present(baz)
      h.should eq({
        _model: 'Baz',
        _label: nil,
        id: nil,
        foo: {
          _model: 'Foo',
          _label: nil,
          id: nil,
          thing: 'thing'
        }
      })
    end
  end

end