require 'deckhand/model_storage/base'

class Deckhand::ModelStorage::Dummy < Deckhand::ModelStorage::Base

  def relation?(model, name)
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

  def query(scope, term, fields)
    fields.map do |name, options|
      OpenStruct.new(model: scope, text: term, match_field: name, match_type: options[:match])
    end
  end

end