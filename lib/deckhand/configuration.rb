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

    attr_accessor :initializer_block, :actions_config, :models_config, :global_config, :model_storage, :plugins
    attr_reader :field_types

    def run
      self.actions_config = {}
      self.models_config = {}
      self.global_config = OpenStruct.new(model_label: [:id])
      DSL.new(self).instance_eval &initializer_block
      build_models_relations
    end

    def reset
      self.models_config = self.global_config = nil
    end

    def action_class(action)
      actions_config.keys.detect {|k| k == action }.camelcase.constantize
    end

    def for_action(action)
      actions_config[action.to_s]
    end

    def has_action?(action)
      actions_config.include? action.to_s
    end

    def actions
      Hash[*actions_config.map { |action, config| [action_class(action), config]}.flatten]
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

    def models_to_list
      models_config.select {|model, config| config.list }.map &:first
    end

    private

    def build_models_relations
      models_config.each do |model, config|
        config.table_fields.each do |name, options|
          class_name = options[:class_name]

          if has_model?(class_name)
            relation_config = for_model(class_name)
            options[:table].each do |column|
              relation_config.add_field_to_include(column)
            end
          end
        end
      end
    end
  end
end