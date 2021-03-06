require 'deckhand/model_storage/base'

class Deckhand::ModelStorage::Dummy < Deckhand::ModelStorage::Base

  def field_type(model, name)
    case name
    when :email
      'string'
    else
      nil
    end
  end

  def field(model, name)
    nil
  end

  def relation_class_name(model, name)
    if model == 'Campaign' && name == :participants
      'Participant'
    else
      nil
    end
  end

  def query(scope, term, fields)
    fields.map do |name, options|
      OpenStruct.new(model: scope, text: term, match_field: name, match_type: options[:match])
    end
  end

end