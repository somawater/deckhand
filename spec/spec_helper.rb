require 'deckhand'
require 'ostruct'
require 'support/dummy_model_storage'

%w[Participant Group Campaign Address Foo Bar Baz].each do |cls|
  eval "#{cls} = Class.new OpenStruct"
end
