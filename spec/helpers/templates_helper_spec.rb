require 'spec_helper'

describe Deckhand::TemplatesHelper do
  describe '#angular_input' do
    let(:name) { 'field_name' }
    subject { helper.angular_input(name, options) }

    context 'with hidden option' do
      let(:options) do
        { hidden: true }
      end

      it 'creates an input[type="hidden"] element' do
        should eq '<input ng-model="field_name" type="hidden"></input>'
      end
    end
  end
end
