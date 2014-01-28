class Deckhand::Presenter

  def initialize(options = {})
    @options = options
  end

  def present(obj, visited = [], fields_to_include = nil)
    model = obj.class.to_s
    return obj unless Deckhand.config.has_model? model
    return core_fields(obj) if visited.include?(obj)

    fields_to_include ||= Deckhand.config.for_model(model).fields_to_include(flat_only: visited.any?)

    fields_to_include.reduce(core_fields(obj)) do |hash, (field, options)|
      if options.try(:[], :lazy_load) && !@options[:eager_load]
        val = []
      else
        val = obj.public_send(field)
      end

      if Deckhand.config.attachment?(model, field)
        val = val.blank? ? nil : val.url
      end

      if options.try(:[], :table)
        subfields_to_include = options[:table].map {|f| [f, {}] }
      elsif options.try(:[], :delegate)
        subfields_to_include = [options[:delegate]]
      end

      hash[field] = if val.is_a?(Enumerable)
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
    if (label = Deckhand.config.for_model(obj.class).label).is_a? Proc
      obj.instance_eval &label
    else
      obj.send label
    end
  end

  def core_fields(obj)
    {_model: obj.class.to_s, _label: label_value(obj), id: obj.id}
  end

end