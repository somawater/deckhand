require 'deckhand'
require 'ostruct'
require 'support/dummy_model_storage'

%w[Foo Bar Baz].each do |cls|
  eval "#{cls} = Class.new OpenStruct"
end
