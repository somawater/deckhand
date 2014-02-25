require 'spec_helper'
require 'deckhand/form'
require File.dirname(__FILE__) + '/../../support/example_form'

describe Deckhand::Form do
  let(:thing) { double('thing') }

  it 'casts params to the correct types and sets defaults' do
    form = ExampleForm.new(object: thing, foo: '45', bar: '35.70', bonk: '40')

    form.foo.should == 45
    form.bar.should == 35.7
    form.baz.should == 42
    form.bonk.should == '40'
    form.here.should be_true
    form.there.should be_false
    form.nowhere.should be_nil
    form.positions.should == []
    form.thing.should == thing
  end

  it 'handles list values' do
    form = ExampleForm.new(
      object: thing,
      positions: [
        {left_side: 'high', 'right_side' => 'low', intensity: '8'},
        {'left_side' => 'low', right_side: 'low', intensity: '3'}
      ]
    )

    form.positions.should == [
      {'left_side' => 'high', 'right_side' => 'low', 'intensity' => 8},
      {'left_side' => 'low', 'right_side' => 'low', 'intensity' => 3}
    ]
  end

  context "with groups" do
    it 'accepts regular inputs' do
      form = ExampleForm.new(album: {title: 'Music for the Jilted Generation'})
      expect(form.album.title).to eq('Music for the Jilted Generation')
    end

    it 'embeds list values within group' do
      form = ExampleForm.new
      expect(form.inputs[:album][:inputs][:songs]).not_to be_nil
    end

    it 'has list values in default' do
      form = ExampleForm.new
      expect(form.inputs[:album][:default]).to eq({songs: []})
    end

    it 'accepts list values' do
      form = ExampleForm.new(album: {songs: [
        {title: 'Voodoo People'},
        {title: 'Poison'},
        {title: 'No Good (Start The Dance)'}
      ]})
      expect(form.album.songs.size).to eq(3)
      expect(form.album.songs.last.title).to eq('No Good (Start The Dance)')
    end
  end
end