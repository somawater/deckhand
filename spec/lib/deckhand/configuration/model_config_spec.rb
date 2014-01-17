require 'spec_helper'
require File.dirname(__FILE__) + '/../../../support/example_config'

describe Deckhand::Configuration::ModelConfig do

  before(:all) { Deckhand.config.run }
  let(:foo_config) { Deckhand.config.for_model(Foo) }

  context '#search_fields' do
    it "reads 'search_on' keywords and options" do
      foo_config.search_fields.should == [
        [:name, {}],
        [:email, {}],
        [:short_id, {:match => :exact}]
      ]
    end
  end

  context '#fields_to_show' do
    before do
      Foo.stub(fields: {email: {}, created_at: {}, password: {}})
    end

    it "reads 'show' keywords and options" do
      fields_to_show = foo_config.fields_to_show
      expect(fields_to_show.first(4)).to eq [
        [:email, {}],
        [:created_at, {}],
        [:bars, {}],
        [:nose, {hairy: false, large: true}]
      ]
      last = fields_to_show.last
      expect(last.first).to eq :virtual_field
      expect(last.last).to be_kind_of Hash
      expect(last.last[:block]).to be_kind_of Proc
    end
  end

  context '#fields_to_include' do
    it 'includes fields used as conditions for actions' do
      expect(foo_config.fields_to_include.map(&:first)).to include :explosive?
    end
  end

  context '#label' do

    before do
      Bar.instance_eval { define_method(:tag) { 'bar' } }
    end

    it 'uses a block defined for the model' do
      expect(foo_config.label).to be_a Proc
    end

    it 'uses a method from model_label if it exists on the model' do
      expect(Deckhand.config.for_model(Bar).label).to eq :tag
    end

  end

end