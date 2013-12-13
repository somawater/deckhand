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
      models_config[model_class] = this_model_config = SimpleDSLStore.new
      this_model_config.instance_eval &block
      this_model_config.freeze
    end
  end

  class Configuration
    include Singleton
    include ConfigurationDSL

    attr_accessor :initializer_block, :models_config

    def initialize
      self.models_config = {}
    end

    def load_initializer_block
      # TODO only allow methods in DSL
      instance_eval &initializer_block
    end

    def models
      @models ||= models_config.keys
    end

    def model_names
      @model_names ||= models.map {|m| m.to_s.underscore }
    end

    def model_search
      @model_search ||= models_config.map do |model, config|
        if config.search_on
          [model, config.search_on]
        end
      end.compact
    end

    def fields_to_show(model)
      mc = models_config[model]
      mc.fields_to_show ||= begin
        mc.show_only || begin
          default_fields = model.fields.keys - ['_id'] + ['id']
          (default_fields + (mc.show || []) - (mc.exclude || []))
        end
      end.flatten.map(&:to_sym).uniq.sort
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