module Deckhand::TemplatesHelper

  def flat_fields
    Deckhand.config.for_model(@model).fields_to_show(flat_only: true)
  end

  def angular_binding(item, name, options = {})
    value = "{{value(#{item}, '#{name}')}}"

    if options[:link_to]
      content_tag :a, value, target: '_blank', 'ng-href' => "{{substitute(#{item}, '#{name}', '#{options[:link_to]}')}}"

    elsif options[:link_to_item]
      relation_name = Deckhand.config.relation_model_name(@model, options[:plural]).to_s.singularize
      ng_click = "showCard('#{relation_name}', #{item}.id)"
      content_tag :a, value, 'ng-click' => ng_click

    elsif Deckhand.config.relation?(@model, name)
      relation_name = Deckhand.config.relation_model_name(@model, name)
      ng_click = "showCard('#{relation_name}', item.#{name}.id)"
      content_tag :a, value, 'ng-click' => ng_click

    elsif options[:html]
      trusted_html value

    else
      value
    end

  end

  def trusted_html(string = nil, &block)
    content_tag :div, '', 'ng-bind-html' => "raw('#{string || block.call}')"
  end

  def table_fields
    Deckhand.config.for_model(@model).fields_to_show.select {|name, options| options[:table] }
  end

  def actions
    Deckhand.config.for_model(@model).actions
  end

  def show_action?(condition)
    condition ? "{{item['#{condition}']}}" : 'true'
  end

  def readable_method_name(name)
    name.to_s.sub(/(_s|!)$/, '').gsub('_', ' ')
  end

  def angular_input(name, options)
    args = {'ng-model' => name, 'class' => 'form-control'}
    if options[:type] == Boolean
      args['type'] = 'checkbox'
      args.delete('class')
    else
      args['type'] = 'text'
    end # TODO more types & HTML5 validators

    if options[:editable] == {with: :ckeditor}
      args['ckeditor'] = true
      content_tag :textarea, '', args
    else
      content_tag :input, '', args
    end

  end

end