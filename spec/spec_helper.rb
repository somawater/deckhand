ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require 'rspec/rails'

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

%w[Participant Group Campaign Address Foo Bar Baz].each do |cls|
  eval "#{cls} = Class.new OpenStruct"
end
