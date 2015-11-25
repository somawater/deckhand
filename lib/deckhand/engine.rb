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
      
      app.config.assets.version = ENV['ASSET_VERSION'] || '1.0'
      app.config.action_controller.asset_host = ENV['ASSET_HOST'] unless ENV['ASSET_HOST'].nil?

      # We don't want the default of everything that isn't js or css, because it pulls too many things in
      app.config.assets.precompile.shift

      # Explicitly register the extensions we are interested in compiling
      app.config.assets.precompile.push(Proc.new do |path|
        File.extname(path).in? [
          '.html', '.erb', '.haml',                 # Templates
          '.png',  '.gif', '.jpg', '.jpeg',         # Images
          '.eot',  '.otf', '.svc', '.woff', '.ttf', # Fonts
        ]
      end)
      
      app.config.assets.precompile += %w[
        deckhand/bootstrap-3.0.3/fonts/glyphicons-halflings-regular.ttf
        deckhand/bootstrap-3.0.3/fonts/glyphicons-halflings-regular.woff
        deckhand/bootstrap-3.0.3/css/bootstrap.css
        deckhand/index.css
        deckhand/theme.css
        deckhand/index.js
      ]
    end

  end
end
