module Deckhand::TemplatesHelper

  def model_config
    @model_config ||= Deckhand.config.for_model(@model)
  end

  def angular_binding(item, name, options = {})

    value = if options[:delegate]
              "{{value(#{item}.#{name}, '#{options[:delegate]}')}}"
            else
              "{{value(#{item}, '#{name}')}}"
            end

    if options[:html]
      content_tag :div, '', 'ng-bind-html' => value.gsub(/^\{\{|\}\}$/, '')

    elsif options[:thumbnail]
      content_tag :a, target: '_blank', 'ng-href' => value do
        content_tag :img, '', 'ng-src' => value
      end

    elsif options[:link_to]
      content_tag :a, value, target: '_blank', 'ng-href' => "{{substitute(#{item}, '#{name}', '#{options[:link_to]}')}}"

    elsif options[:link_to_item]
      ng_click = "showCard(#{item}._model, #{item}.id)"
      content_tag :a, value, 'ng-click' => ng_click

    elsif Deckhand.config.relation?(@model, name)
      ng_click = "showCard(#{item}.#{name}._model, #{item}.#{name}.id)"
      content_tag :a, value, 'ng-click' => ng_click

    else
      value
    end

  end

  def show_action?(condition)
    condition ? "item['#{condition}']" : 'true'
  end

  def readable_method_name(name)
    name.to_s.sub(/(_s|!)$/, '').gsub('_', ' ').capitalize
  end

  def angular_input(name, options)
    args = {'ng-model' => name, 'class' => 'form-control'}

    if options[:type] == :boolean
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
