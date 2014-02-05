require 'spec_helper'
require File.dirname(__FILE__) + '/../../../support/example_config'

describe Deckhand::Configuration::ModelConfig do

  before(:all) { Deckhand.config.run }
  subject { Deckhand.config.for_model(Participant) }

  context '#search_options' do
    it "reads 'search_on' and 'search_scope' keywords" do
      Deckhand.config.for_model(Participant).search_options.should == {
        scope: :verified,
        fields: [
          [:name, {}],
          [:email, {}],
          [:shortcode, {:match => :exact}]
        ]
      }
    end
  end

  context '#fields_to_show' do
    it "reads 'show' keywords and options, adding types and names" do
      expect(Deckhand.config.for_model(Participant).fields_to_show).to eq [
        [:email, {type: 'string', name: :email}],
        [:created_at, {type: nil, name: :created_at}],
        [:groups, {type: nil, name: :groups}],
        [:twitter_handle, {link_to: 'http://twitter.com/:value', type: nil, name: :twitter_handle}],
        [:address, {delegate: :summary, html: true, editable: {nested: true}, type: nil, name: :address}],
        [:text_messages, {table: [:created_at, :text], lazy_load: true, type: nil, name: :text_messages}]
      ]
    end
  end

  context '#fields_to_include' do
    it 'includes fields used as conditions for actions' do
      fields_to_include = Deckhand.config.for_model(Participant).fields_to_include
      expect(fields_to_include).to include [:promotable?, {type: nil, name: :promotable?}]
    end

    it 'includes fields used in tables by related models' do
      fields_to_include = Deckhand.config.for_model(Participant).fields_to_include
      expect(fields_to_include).to include [:last_active_at, {type: nil, name: :last_active_at}]
    end

    it 'includes class_name for relations' do
      fields_to_include = Deckhand.config.for_model(Campaign).fields_to_include
      expect(fields_to_include).to include [:participants, {
        table: [:name, :email, :last_active_at],
        type: :relation,
        name: :participants,
        class_name: 'Participant'
      }]
    end
  end

  context 'fields_to_edit' do
    before do
      Group.stub attachment_definitions: {logo: {}}
    end

    it 'auto-detects Paperclip fields' do
      Deckhand.config.attachment?(Group, :logo).should be_true
      fields_to_edit = Deckhand.config.for_model(Group).fields_to_edit
      logo_config = fields_to_edit.detect {|x| x.first == :logo }.last
      expect(logo_config[:type]).to eq :file
    end

    it 'excludes fields that have their own nested forms' do
      Deckhand.config.for_model(Participant).fields_to_edit.map(&:first).should_not include :address
    end
  end

  context '#label' do

    before do
      Group.instance_eval { define_method(:name) { some_name } }
    end

    it 'uses a block defined for the model' do
      expect(Deckhand.config.for_model(Participant).label).to be_a Proc
    end

    it 'uses a method from model_label if it exists on the model' do
      expect(Deckhand.config.for_model(Group).label).to eq :name
    end
  end

end