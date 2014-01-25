require 'spec_helper'
require File.dirname(__FILE__) + '/../../support/example_config'

describe Deckhand::Configuration do

  before(:all) { Deckhand.config.run }
  let(:config) { Deckhand.config }

  it 'reads model_label' do
    expect(config.global_config.model_label).to eq [:pretty_name, :name, :tag, :id]
  end

  it 'reads model_storage' do
    expect(config.global_config.model_storage).to be_kind_of Deckhand::ModelStorage::Dummy
  end

  context '#field_types' do
    it "sets type to 'html' when specified" do
      Deckhand.config.field_types['Participant'][:summary] = :html
    end
  end

end