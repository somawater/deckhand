require 'spec_helper'
require 'deckhand/open_struct_without_table'

describe Deckhand::OpenStructWithoutTable do
  context "#to_json" do
    it "skips table element" do
      subject = described_class.new({a: 1, b: 2})
      expect(subject.to_json).to eq('{"a":1,"b":2}')
    end
  end
end