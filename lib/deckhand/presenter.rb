class Deckhand::Presenter

  def present(obj, visited = [], fields_to_include = nil)
    model = obj.class
    return obj unless Deckhand.config.has_model? model
    return core_fields(obj) if visited.include?(obj)

    fields_to_include ||= Deckhand.config.fields_to_include(model, flat_only: visited.any?)

    fields_to_include.reduce(core_fields(obj)) do |hash, (field, options)|
      val = obj.public_send(field)
      val = val.public_send(options[:delegate]) if options[:delegate]
      subfields_to_include = options[:table].map {|f| [f, {}] } if options[:table]

      hash[field] = if val.is_a?(Array)
        val.map {|subval| present(subval, visited + [obj], subfields_to_include) }
      else
        present val, visited + [obj], subfields_to_include
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