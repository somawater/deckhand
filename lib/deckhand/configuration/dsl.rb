require 'deckhand/configuration/model_dsl'

class Deckhand::Configuration::DSL

  def initialize(config)
    @config = config
  end

  def model(model_class, &block)
    @config.models_config[model_class] = Deckhand::Configuration::ModelDSL.new({
      singular: [:label, :fields_to_show],
      defaults: {show: [], exclude: []}
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