require 'spec_helper'
require 'deckhand/form'
require File.dirname(__FILE__) + '/../../support/example_form'

describe Deckhand::Form do
  let(:thing) { double('thing') }

  context "with regular parameters" do
    it 'casts params to the correct types' do
      form = ExampleForm.new(object: thing, foo: '45', bar: '35.70', bonk: '40')
      expect(form.foo).to eq(45)
      expect(form.bar).to eq(35.7)
      expect(form.bonk).to eq('40')
    end

    it 'respects defaults' do
      form = ExampleForm.new(object: thing, foo: '45', bar: '35.70')
      expect(form.baz).to eq(42)
      expect(form.bonk).to eq(41)
      expect(form.here).to be_true
      expect(form.there).to be_false
      expect(form.nowhere).to be_nil
      expect(form.positions).to eq([])
      expect(form.thing).to eq(thing)
      expect(form.marital_status).to eq('m')
    end
    
    it "has choices" do
      form = ExampleForm.new
      expect(form.values[:marital_status][:choices]).to eq([['Single', 's'], ['Married', 'm']])
    end
  end

  context "with list parameters" do
    it 'defaults list values to empty array' do
      form = ExampleForm.new
      expect(form.inputs[:positions][:default]).to eq([])
    end

    it 'defines list parameters members defaults' do
      form = ExampleForm.new
      expect(form.inputs[:positions][:inputs][:intensity][:default]).to eq(100)
    end

    it 'respects list parameters members defaults' do
      form = ExampleForm.new(
        object: thing,
        positions: [{}]
      )
      expect(form.positions.first[:intensity]).to eq(100)
    end

    it 'accepts multiple values' do
      form = ExampleForm.new(
        object: thing,
        positions: [
          {left_side: 'high', 'right_side' => 'low', intensity: '8'},
          {'left_side' => 'low', right_side: 'high', intensity: '3'}
        ]
      )

      expect(form.positions.size).to eq(2)

      expect(form.positions.first.left_side).to eq('high')
      expect(form.positions.first.right_side).to eq('low')
      expect(form.positions.first.intensity).to eq(8)

      expect(form.positions.last.left_side).to eq('low')
      expect(form.positions.last.right_side).to eq('high')
      expect(form.positions.last.intensity).to eq(3)
    end

    it "has choices" do
      form = ExampleForm.new
      expect(form.values[:positions][:inputs][:preference][:choices]).to eq([['Left', 1], ['Right', 2]])
    end

    it "respects default value for choices" do
      form = ExampleForm.new
      expect(form.values[:positions][:inputs][:preference][:value]).to eq(2)
    end
  end


  context "with groups" do
    it 'accepts regular inputs' do
      form = ExampleForm.new(album: {title: 'Music for the Jilted Generation'})
      expect(form.album.title).to eq('Music for the Jilted Generation')
    end

    it 'defines default values for regular inputs' do
      form = ExampleForm.new
      expect(form.inputs[:album][:inputs][:title][:default]).to eq("YMCA")
    end

    it 'respects default values for regular inputs' do
      form = ExampleForm.new
      expect(form.album.title).to eq("YMCA")
    end

    it 'embeds list values within group' do
      form = ExampleForm.new
      expect(form.inputs[:album][:inputs][:songs]).not_to be_nil
    end

    it 'defines list values default to empty array' do
      form = ExampleForm.new
      expect(form.inputs[:album][:default][:songs]).to eq([])
    end

    it 'respects list values defaults' do
      form = ExampleForm.new(album: {songs: [{}]})
      expect(form.album.songs.first.remix).to eq(true)
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

    it "has choices" do
      form = ExampleForm.new
      expect(form.values[:album][:inputs][:play_speed][:choices]).to eq([['LP', 33], ['SP', 45]])
    end

    it "respects default value for choices" do
      form = ExampleForm.new
      expect(form.values[:album][:inputs][:play_speed][:value]).to eq(33)
    end
  end
end