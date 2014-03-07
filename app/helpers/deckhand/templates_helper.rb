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

    if options[:model]
      args['type'] = 'text'
      args['typeahead'] = "object as object._label for object in search($viewValue, '#{options[:model]}')"
      args['typeahead-loading'] = "loading_#{parameterize(name)}"
      args['typeahead-template-url'] = 'typeahead-search'
      args['typeahead-on-select'] = 'select()'
      args['typeahead-wait-ms'] = '300'
      args['placeholder'] = options[:placeholder] || 'Start typing ...'
    elsif options[:type] == :boolean
      args['type'] = 'checkbox'
      args.delete('class')
    elsif options[:type] == :file
      args['type'] = 'file'
      args['ng-file-select'] = "onFileSelect($files, '#{name}')"
      args.delete('ng-model')
    elsif options[:type] == Time
      args.delete('class')
    elsif options[:type] == Integer
      args['type'] = 'number'
    elsif options[:type] == Float
      args['type'] = 'number'
      args['step'] = 0.01
    elsif options[:choices]
      # nothing
    else
      args['type'] = 'text'
      args['placeholder'] = options[:placeholder] if options[:placeholder]
    end # TODO more types & HTML5 validators

    if options[:choices]
      content_tag(:select, '', args) do
        content_tag :option, '{{choice[0]}}', 'ng-repeat' => "choice in choicesForSelect['#{name}']", 'ng-value' => 'choice[1]'
      end
    elsif options[:editable] == {with: :textarea}
      args['rows'] = 4
      content_tag :textarea, '', args
    elsif options[:editable] == {with: :ckeditor}
      args['ckeditor'] = true
      content_tag :textarea, '', args
    elsif options[:type] == Time
      content_tag :div, content_tag(:timepicker), args
    elsif options[:model]
      content_tag(:span, '', class: 'modal-search') do
        content_tag(:i, '', class: 'glyphicon glyphicon-search', "ng-class" => "{loading: loading_#{parameterize(name)}}") +
        content_tag(:input, '', args)
      end
    else
      content_tag :input, '', args
    end

  end

  def parameterize(string)
    string.gsub('.', '_')
  end

  def defaults_for_new_multiple_item(multiple)
    return {} unless multiple && multiple[:inputs]
    multiple[:inputs].reduce({}) {|defaults, (name, options)| defaults[name] = options[:default]; defaults }.to_json
  end
end
