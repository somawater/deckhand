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
      models[model_class] = model_config = SimpleDSLStore.new
      model_config.instance_eval &block
      model_config.freeze
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

    def searchable_models
      @searchable_models ||= models.map do |model, config|
        if config.search_on
          [model, config.search_on]
        end
      end.compact
    end

  end

  class SimpleDSLStore
    def initialize
      @store = {}
    end

    def method_missing(sym, *args)
      if args.none? && frozen?
        @store[sym]
      else
        if @store.include? sym
          @store[sym] << args
        else
          @store[sym] = [args]
        end
      end
    end

  end

end