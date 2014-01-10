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
        [model, config.search_on] if config.search_on
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

    def has_model?(model)
      models_by_name.keys.include? model.to_s
    end

    def fields_to_show(model)
      models_config[model].show
    end

    # a model's label can either be a symbol name of a method on that model,
    # or a block that will be eval'ed in instance context.
    # it can be defined in the model's configuration block with the "label" keyword,
    # or fall back to the "model_label" keyword at the top level of configuration.
    # the top-level configuration only supports methods, not blocks.
    def label(model)
      models_config[model].label ||= global_config[:model_label].instance_eval do
        detect {|attr| model.method_defined? attr } || last
      end
    end

    private

    def setup_field_types
      @field_types = models_config.keys.reduce({}) do |types, model|
        types[model.to_s] = fields_to_show(model).reduce({}) do |h, (name, options)|
          h[name] = @model_storage.field_type(model, name); h
        end
        types
      end
    end

  end

end