require 'deckhand/configuration/model_config'
require 'deckhand/configuration/simple_dsl'

class Deckhand::Configuration::DSL

  def initialize(config)
    @config = config
  end

  def model(model_class, &block)
    @config.models_config[model_class] = Deckhand::Configuration::ModelConfig.new({
      model: model_class,
      singular: [:label, :fields_to_show],
      defaults: {show: [], exclude: []},
      label_defaults: @config.global_config.model_label
    }, &block)
  end

  def model_label(*methods)
    @config.global_config.model_label = methods + @config.global_config.model_label
  end

  def model_storage(sym)
    class_name = "Deckhand::ModelStorage::#{sym.to_s.camelize}"
    unless (class_name.constantize rescue nil)
      require "deckhand/model_storage/#{sym}"
    end
    @config.global_config.model_storage = class_name.constantize.new
  end

  def plugins(&block)
    @config.global_config.plugins = Deckhand::Configuration::SimpleDSL.new(&block)
  end

end