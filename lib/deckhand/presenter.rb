class Deckhand::Presenter

  def present(obj, visited = [])
    model = obj.class
    return obj unless Deckhand.config.has_model? model
    return core_fields(obj) if visited.include?(obj)

    Deckhand.config.fields_to_show(model).reduce(core_fields(obj)) do |hash, (field, options)|
      val = obj.send(field)
      val = val.send(options[:delegate]) if options[:delegate]
      hash[field] = if val.is_a?(Array)
        val.map {|subval| present(subval, visited + [obj]) }
      else
        present val, visited + [obj]
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