module Deckhand::TemplatesHelper

  def flat_fields
    Deckhand.config.fields_to_show(@model, flat_only: true)
  end

  def angular_binding(item, name, options = {})
    value = "{{value(#{item}, '#{name}')}}"

    if options[:link_to]
      content_tag :a, value, target: '_blank', 'ng-href' => "{{substitute(#{item}, '#{name}', '#{options[:link_to]}')}}"

    elsif options[:link_to_item]
      relation_name = Deckhand.config.relation_model_name(@model, options[:plural]).to_s.singularize
      ng_click = "open('#{relation_name}', #{item}.id)"
      content_tag :a, value, 'ng-click' => ng_click

    elsif Deckhand.config.link?(@model, name)
      relation_name = Deckhand.config.relation_model_name(@model, name)
      ng_click = "open('#{relation_name}', item.#{name}.id)"
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
    Deckhand.config.fields_to_show(@model).select {|name, options| options[:table] }
  end

  def actions
    Deckhand.config.actions(@model)
  end

  def show_action?(condition)
    condition ? "{{item['#{condition}']}}" : 'true'
  end

  def readable_field_name(name)
    name.to_s.sub(/_s$/, '').gsub('_', ' ')
  end

  def readable_action_name(name)
    name.to_s.sub(/!$/, '')
  end

end