require 'spec_helper'
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
    form.thing.should == thing
  end

end