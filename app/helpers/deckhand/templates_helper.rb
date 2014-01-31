module Deckhand::TemplatesHelper

  def model_config
    @model_config ||= Deckhand.config.for_model(@model)
  end

  def show_action?(condition)
    condition ? "item['#{condition}']" : 'true'
  end

  def readable_method_name(name)
    name.to_s.sub(/(_s|!)$/, '').gsub('_', ' ').capitalize
  end

  def angular_input(name, options)
    args = {'ng-model' => name, 'class' => 'form-control'}

    if options[:model]
      args['typeahead'] = "object for object in getObjectsTypeahead($viewValue, '#{options[:model]}')"
    elsif options[:type] == :boolean
      args['type'] = 'checkbox'
      args.delete('class')
    elsif options[:type] == :file
      args['type'] = 'file'
      args['ng-file-select'] = "onFileSelect($files, '#{name}')"
      args.delete('ng-model')
    elsif options[:choices]
      # nothing
    else
      args['type'] = 'text'
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
    else
      content_tag :input, '', args
    end

  end

end
