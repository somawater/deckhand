$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "deckhand/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "deckhand"
  s.version     = Deckhand::VERSION
  s.authors     = ["Lawrence Wang"]
  s.email       = ["lawrence@drinksoma.com"]
  s.homepage    = "https://github.com/somawater/deckhand"
  s.summary     = "It handles the money."
  s.description = "Wrapper for Braintree and PayPal Express Checkout."

  s.files = Dir["{app,config,db,lib}/**/*"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'sprockets-browserify'
end
