require 'sprockets/browserify'
require 'sprockets/browserify/engine'

module Deckhand
  class Engine < ::Rails::Engine

    config.to_prepare do
      Deckhand::Configuration.instance.load_initializer_block
    end

    initializer :setup_browserify, :after => "sprockets.environment", :group => :all do |app|
      app.assets.register_postprocessor 'application/javascript', Sprockets::Browserify
    end

  end
end
