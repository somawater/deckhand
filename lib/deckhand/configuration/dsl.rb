require 'deckhand/configuration/action_config'
require 'deckhand/configuration/model_config'
require 'deckhand/configuration/simple_dsl'

class Deckhand::Configuration::DSL

  def initialize(config)
    @config = config
  end

  def action(action_class, options)
    default_options = {action: action_class}
    action_config = Deckhand::Configuration::ActionConfig.new(options.merge(default_options))
    @config.global.actions[action_class.to_sym] = action_config
  end

  def model(model_class, &block)
    options = {model: model_class, label_defaults: @config.global.model_label}
    model_config = Deckhand::Configuration::ModelConfig.new(options, &block)
    @config.models[model_class.to_s] = model_config
  end

  def model_label(*methods)
    @config.global.model_label = methods + @config.global.model_label
  end

  def model_storage(sym)
    class_name = "Deckhand::ModelStorage::#{sym.to_s.camelize}"
    unless (class_name.constantize rescue nil)
      require "deckhand/model_storage/#{sym}"
    end
    @config.model_storage = class_name.constantize.new
  end

  def plugins(&block)
    @config.plugins = Deckhand::Configuration::SimpleDSL.new(singular: [:ckeditor], &block)
  end

end