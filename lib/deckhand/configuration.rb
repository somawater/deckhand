require 'singleton'

module Deckhand

  def self.configure(&block)
    Configuration.instance.initializer_block = block
  end

  def self.config
    Configuration.instance
  end

  class Configuration
    include Singleton

    attr_accessor :initializer_block, :models

    def initialize
      self.models = {}
    end

    def load_initializer_block
      instance_eval &initializer_block
    end

    def model(model_class, &block)
      models[model_class] = block
    end

  end

end