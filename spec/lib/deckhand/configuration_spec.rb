require 'spec_helper'
require File.dirname(__FILE__) + '/../../support/example_config'

describe Deckhand::Configuration do

  before(:all) { Deckhand.config.run }
  let(:config) { Deckhand.config }

  it 'reads model_label' do
    expect(config.global.model_label).to eq [:pretty_name, :name, :tag, :id]
  end

  it 'reads model_storage' do
    expect(config.model_storage).to be_kind_of Deckhand::ModelStorage::Dummy
  end

  it 'adds top-level actions' do
    action_config = config.global.actions[:start_conversation]
    expect(action_config).to be_kind_of Deckhand::Configuration::ActionConfig
    expect(action_config.label).to eq 'Start talking'
  end

end