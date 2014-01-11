module Deckhand::TemplatesHelper

  def flat_fields
    Deckhand.config.fields_to_show(@model, flat_only: true)
  end

  def angular_binding(name, options = {})
    parent = options[:parent] || 'item'
    value = "{{value(#{parent}, '#{name}')}}"
    if options[:link]
      relation_name = parent.capitalize
      ng_click = "open('#{relation_name}', #{parent}.id)"
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
    Deckhand.config.models_config[@model].action || []
  end

  def readable_field_name(name)
    name.to_s.sub(/_s$/, '').gsub('_', ' ')
  end

end