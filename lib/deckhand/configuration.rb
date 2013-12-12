require 'singleton'

module Deckhand

  def self.configure(&block)
    Configuration.instance.initializer_block = block
  end

  def self.config
    Configuration.instance
  end

  module ConfigurationDSL
    def model(model_class, &block)
      models[model_class] = block
    end
  end

  class Configuration
    include Singleton
    include ConfigurationDSL

    attr_accessor :initializer_block, :models

    def initialize
      self.models = {}
    end

    def load_initializer_block
      # TODO only allow methods in DSL
      instance_eval &initializer_block
    end

    def model_names
      @model_names ||= models.keys.map {|m| m.to_s.underscore.parameterize.dasherize }
    end

  end

end