require 'deckhand'
require 'ostruct'

%w[Foo Bar Baz].each do |cls|
  eval "#{cls} = Class.new OpenStruct"
end
