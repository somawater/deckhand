require 'sprockets/browserify'
require 'sprockets/browserify/engine'

module Deckhand
  class Engine < ::Rails::Engine

    config.to_prepare do
      if Rails.env.development?
        load Rails.root.join('config/initializers/deckhand.rb')
      end
      Deckhand.config.run
    end

    initializer 'deckhand.setup_browserify', :after => "sprockets.environment", :group => :all do |app|
      app.assets.register_postprocessor 'application/javascript', Sprockets::Browserify
    end

    initializer 'deckhand.assets_precompile', :group => :all do |app|
      app.config.assets.precompile += %w[
        deckhand/bootstrap-3.0.3/css/bootstrap.css
        deckhand/index.css
        deckhand/theme.css
        deckhand/index.js
      ]
    end

  end
end
