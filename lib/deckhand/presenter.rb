class Deckhand::Presenter

  def initialize(options = {})
    @options = options
  end

  def present(obj, fields = nil)
    model = obj.class.to_s
    return obj unless Deckhand.config.has_model? model

    fields ||= Deckhand.config.for_model(model).fields_to_include
    fields += build_choices_fields(obj, fields)

    fields.reduce(core_fields(obj)) do |hash, (field, options)|
      if options.try(:[], :lazy_load) && !@options[:eager_load]
        val = []
      elsif options && options[:is_choice]
        val = options[:choices]
      else
        val = obj.public_send(field)
      end

      if Deckhand.config.attachment?(model, field)
        val = val.blank? ? nil : val.url
      end

      subfields = if options.try(:[], :table)
        options[:table].map {|f| [f, {}] }
      elsif options.try(:[], :delegate)
        [options[:delegate]]
      else
        []
      end

      hash[field] = if val.is_a?(Enumerable)
        val.map {|subval| present(subval, subfields) }
      else
        present val, subfields
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

  private

  def build_choices_fields(obj, fields)
    fields.map do |field, options|
      if options && options[:choices]
        name = "#{field}_choices"
        choices_options = {choices: build_choices(obj, options), name: name, is_choice: true}
        [name.to_sym, options.merge(choices_options)]
      end
    end - [nil]
  end

  def build_choices(obj, options)
    choices = options[:choices].is_a?(Symbol) ? obj.send(options[:choices]) : options[:choices]
    choices.map {|choice| wrap_choice(choice)}
  end

  def wrap_choice(choice)
    if choice.kind_of?(Array)
      value = choice[0]
      key = choice[1] || value
    elsif choice.kind_of?(Hash)
      key = choice[:key] || choice[choice.keys[0]]
      value = choice[:value] || choice[choice.keys[1]] || key
    else
      key = value = choice
    end
    {key: key, value: value}
  end
end