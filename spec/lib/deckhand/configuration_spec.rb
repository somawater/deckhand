require 'spec_helper'
require File.dirname(__FILE__) + '/../../support/example_config'

describe Deckhand::Configuration do

  before(:all) { Deckhand.config.run }
  subject { Deckhand.config }

  it 'reads model_label' do
    expect(subject.global_config[:model_label]).to eq [:pretty_name, :name, :tag, :id]
  end

  it 'reads model_storage' do
    expect(subject.global_config[:model_storage]).to be_kind_of Deckhand::ModelStorage::Dummy
  end

  context '#fields_to_show' do
    before do
      Foo.stub(fields: {email: {}, created_at: {}, password: {}})
    end

    it "reads 'show' keywords and options" do
      fields_to_show = subject.fields_to_show(Foo)
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
      expect(subject.fields_to_include(Foo).map(&:first)).to include :explosive?
    end
  end

  context '#label' do

    before do
      Bar.instance_eval { define_method(:tag) { 'bar' } }
    end

    it 'uses a block defined for the model' do
      expect(subject.label(Foo)).to be_a Proc
    end

    it 'uses a method from model_label if it exists on the model' do
      expect(subject.label(Bar)).to eq :tag
    end

  end

end