require 'deckhand/model_storage/base'

class Deckhand::ModelStorage::Dummy < Deckhand::ModelStorage::Base

  def link?(model, name)
    false
  end

  def relation_model_name(model, name)
    name
  end

  def field_type(model, name)
    nil
  end

  def field(model, name)
    nil
  end

  def relation(model, name)
    nil
  end

  def search(term)
    search_config.map do |model, search_fields|
      search_fields.map do |name, options|
        OpenStruct.new(model: model, text: term, match_field: name, match_type: options[:match])
      end
    end.flatten(1)
  end

end