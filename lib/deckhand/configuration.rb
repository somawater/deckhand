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

    attr_accessor :initializer_block, :models, :global, :model_storage, :plugins
    attr_reader :field_types

    def run
      self.models = {}
      self.global = OpenStruct.new(model_label: [:id], actions: {})
      DSL.new(self).instance_eval(&initializer_block)
      build_models_relations
    end

    def reset
      self.models = self.global = nil
    end

    def model_class(model)
      models.keys.detect {|k| k == model }.constantize
    end

    def for_model(model)
      models[model.to_s]
    end

    def has_model?(model)
      models.include? model.to_s
    end

    def action_form_class(action)
      global.actions[action.to_sym].try :form_class
    end

    def has_action?(action)
      global.actions.include? action.to_sym
    end

    def attachment?(model, name)
      # this is specific to Paperclip
      model.respond_to?(:attachment_definitions) and model.attachment_definitions.try(:include?, name)
    end

    def models_to_list
      models.select {|model, config| config.list }.map &:first
    end

    private

    def build_models_relations
      models.each do |model, config|
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
