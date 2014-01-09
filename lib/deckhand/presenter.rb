class Deckhand::Presenter

  def present(obj)
    model = obj.class
    return obj unless Deckhand.config.has_model? model

    Deckhand.config.fields_to_show(model).reduce(core_fields(obj)) do |hash, field|
      val = obj.send(field)
      hash[field] = if val.is_a?(Array)
        val.map {|subval| present(subval) }
      else
        present val
      end
      hash
    end
  end

  def present_results(results)
    results.map {|obj| core_fields(obj) }
  end

  def label_value(obj)
    if (label = Deckhand.config.label(obj.class)).is_a? Proc
      obj.instance_eval &label
    else
      obj.send label
    end
  end

  def core_fields(obj)
    {_model: obj.class.to_s, _label: label_value(obj), id: obj.id}
  end

end