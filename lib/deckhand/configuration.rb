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

    attr_accessor :initializer_block, :models_config, :global_config, :model_storage, :plugins
    attr_reader :field_types

    def run
      self.models_config = {}
      self.global_config = OpenStruct.new(model_label: [:id])

      DSL.new(self).instance_eval &initializer_block

      setup_field_types
    end

    def reset
      self.models_config = self.global_config = nil
    end

    def model_class(model)
      models_config.keys.detect {|k| k == model }.constantize
    end

    def for_model(model)
      models_config[model.to_s]
    end

    def has_model?(model)
      models_config.include? model.to_s
    end

    def attachment?(model, name)
      # this is specific to Paperclip
      model.respond_to?(:attachment_definitions) and model.attachment_definitions.try(:include?, name)
    end

    private

    def setup_field_types
      @field_types = models_config.reduce({}) do |types, (model, config)|
        types[model] = config.fields_to_include.reduce({}) do |h, (name, options)|
          h[name] = (options[:lazy_load] ? :lazy_table : model_storage.field_type(model, name))
          h
        end
        types
      end
    end

  end

end