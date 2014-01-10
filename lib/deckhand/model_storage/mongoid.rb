class Deckhand::ModelStorage::Mongoid

  def link?(model, name)
    model.relations.include? name.to_s
  end

  def relation_model_name(model, name)
    relation(model, name).instance_eval do
      self[:class_name] || self[:name].to_s.camelize
    end
  end

  def field_type(model, name)
    if f = field(model, name)
      f.options[:type].to_s.underscore
    elsif r = relation(model, name)
      :relation
    end
  end

  def field(model, name)
    model.fields.detect {|f| f.first == name.to_s }.last rescue nil
  end

  def relation(model, name)
    model.relations[name.to_s]
  end

end