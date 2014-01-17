module Deckhand
  class Configuration; end
end

require 'deckhand/configuration/dsl'
require 'singleton'

module Deckhand

  module ModelStorage; end

  def self.configure(&block)
    Configuration.instance.initializer_block = block
  end

  def self.config
    Configuration.instance
  end

  class Configuration
    include Singleton

    attr_accessor :initializer_block, :models_config, :global_config
    attr_reader :search_config, :models_by_name, :field_types

    def run
      self.models_config = {}
      self.global_config = {model_label: [:id]}

      DSL.new(self).instance_eval &initializer_block

      @search_config = models_config.map do |model, config|
        [model, config.search_fields] if config.search_fields
      end.compact

      names = models_config.keys.map {|m| [m.to_s, m] }.flatten
      @models_by_name = Hash[*names]

      if @model_storage = global_config[:model_storage]
        setup_field_types
      end
    end

    delegate :link?, :relation_model_name, :to => :@model_storage

    def reset
      self.models_config = self.global_config = nil
    end

    def for_model(model)
      models_config[model]
    end

    def has_model?(model)
      models_by_name.keys.include? model.to_s
    end

    private

    def setup_field_types
      @field_types = models_config.reduce({}) do |types, (model, config)|
        types[model.to_s] = config.fields_to_include.reduce({}) do |h, (name, options)|
          h[name] = @model_storage.field_type(model, name); h
        end
        types
      end
    end

  end

end