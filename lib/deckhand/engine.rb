module Deckhand
  class Engine < ::Rails::Engine

    initializer 'extensions' do
      # require 'admin/extensions/subscription_event.rb'
    end

    config.to_prepare do
      Deckhand::Configuration.instance.load_initializer_block
    end

  end
end
