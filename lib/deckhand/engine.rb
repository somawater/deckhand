module Deckhand
  class Engine < ::Rails::Engine

    config.to_prepare do
      Deckhand::Configuration.instance.load_initializer_block
    end

  end
end
