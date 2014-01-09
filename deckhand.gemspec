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
  s.summary     = "A card-based admin UI."
  s.description = "A card-based admin UI with an easy-to-use configuration DSL."

  s.files = Dir["{app,config,db,lib}/**/*"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'sprockets-browserify'
end
