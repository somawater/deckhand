require 'deckhand/configuration/model_config'

class Deckhand::Configuration::DSL

  def initialize(config)
    @config = config
  end

  def model(model_class, &block)
    @config.models_config[model_class] = Deckhand::Configuration::ModelConfig.new({
      model: model_class,
      singular: [:label, :fields_to_show],
      defaults: {show: [], exclude: []},
      label_defaults: @config.global_config[:model_label]
    }, &block)
  end

  def model_label(*methods)
    @config.global_config[:model_label] = methods + @config.global_config[:model_label]
  end

  def model_storage(sym)
    require "deckhand/model_storage/#{sym}"
    @config.global_config[:model_storage] = Deckhand::ModelStorage.const_get(sym.to_s.camelize).new
  end

end