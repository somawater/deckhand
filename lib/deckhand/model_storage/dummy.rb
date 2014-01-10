class Deckhand::ModelStorage::Dummy

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

end