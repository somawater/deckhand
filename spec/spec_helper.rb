require 'deckhand'
require 'ostruct'
require 'support/dummy_model_storage'

%w[Foo Bar Baz Quux].each do |cls|
  eval "#{cls} = Class.new OpenStruct"
end
