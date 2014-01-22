require 'spec_helper'

describe Deckhand::Form do
  before(:all) do
    ExampleForm = Class.new
    ExampleForm.instance_eval do
      include Deckhand::Form

      input :foo, type: Integer
      input :bar, type: Float
    end
  end

  it 'casts params to the correct types' do
    form = ExampleForm.new
    form.consume_params(foo: '45', bar: '35.70')
    form.foo.should == 45
    form.bar.should == 35.7
  end

end