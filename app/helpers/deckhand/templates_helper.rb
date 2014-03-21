module Deckhand::TemplatesHelper

  def show_action?(condition, unless_condition)
    if condition
      "item['#{condition}']"
    elsif unless_condition
      "!item['#{unless_condition}']"
    else
      'true'
    end
  end

  def readable_method_name(name)
    name.to_s.sub(/(_s|!)$/, '').gsub('_', ' ').capitalize
  end

  def angular_input(name, options)
    args = {'ng-model' => name, 'class' => 'form-control'}

    # TODO more types & HTML5 validators, chain pattern
    return build_typeahead_input(args, name, options)   if options[:model]
    return build_checkbox(args)                         if options[:type] == :boolean
    return build_file_upload(args, name)                if options[:type] == :file
    return build_time_picker(args)                      if options[:type] == Time
    return build_integer_picker(args)                   if options[:type] == Integer
    return build_float_picker(args)                     if options[:type] == Float
    return build_select_input(args, name, options)      if options[:choices]
    return build_hidden_input(args, options)            if options[:hidden]

    build_text_input(args, options)
  end

  def parameterize(string)
    string.gsub('.', '_')
  end

  def defaults_for_new_multiple_item(multiple)
    return {} unless multiple && multiple[:inputs]
    multiple[:inputs].reduce({}) {|defaults, (name, options)| defaults[name] = options[:default]; defaults }.to_json
  end

  private

  def build_typeahead_input(args, name, options)
    args['type'] = 'text'
    args['typeahead'] = "object as object._label for object in search($viewValue, '#{options[:model]}')"
    args['typeahead-loading'] = "loading_#{parameterize(name)}"
    args['typeahead-template-url'] = 'typeahead-search'
    args['typeahead-on-select'] = 'select()'
    args['typeahead-wait-ms'] = '300'
    args['placeholder'] = options[:placeholder] || 'Start typing ...'
    content_tag(:span, '', class: 'modal-search') do
      content_tag(:i, '', class: 'glyphicon glyphicon-search', "ng-class" => "{loading: loading_#{parameterize(name)}}") +
        content_tag(:input, '', args)
    end
  end

  def build_checkbox(args)
    args['type'] = 'checkbox'
    args.delete('class')
    content_tag :input, '', args
  end

  def build_file_upload(args, name)
    args['type'] = 'file'
    args['ng-file-select'] = "onFileSelect($files, '#{name}')"
    args.delete('ng-model')
    content_tag :input, '', args
  end

  def build_time_picker(args)
    args.delete('class')
    content_tag :div, content_tag(:timepicker), args
  end

  def build_integer_picker(args)
    args['type'] = 'number'
    content_tag :input, '', args
  end

  def build_float_picker(args)
    args['type'] = 'number'
    args['step'] = 0.01
    content_tag :input, '', args
  end

  def build_select_input(args, name, options)
    content_tag(:select, '', args) do
      content_tag :option, '{{choice[0]}}',
                  'ng-repeat' => "choice in choicesForSelect['#{name}']",
                  'ng-value' => 'choice[1]',
                  'ng-selected' => "'#{options[:default]}' == choice[1]"
    end
  end

  def build_text_input(args, options)
    args['type'] = 'text'
    args['placeholder'] = options[:placeholder] if options[:placeholder]

    if options[:editable] == {with: :textarea}
      args['rows'] = 4
    elsif options[:editable] == {with: :ckeditor}
      args['ckeditor'] = true
    end

    content_tag :textarea, '', args
  end

  def build_hidden_input(args, options)
    args['type'] = 'hidden'
    args.delete('class')
    content_tag :input, '', args
  end
end
