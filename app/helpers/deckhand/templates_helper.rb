module Deckhand::TemplatesHelper

  def fields_to_show
    Deckhand.config.fields_to_show @model
  end

  def angular_binding(name, options = {})
    parent = options[:parent] || 'item'
    value = "{{value(#{parent}, '#{name}')}}"
    if Deckhand.config.link?(@model, name)
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

  def relations_to_tabulate
    [] # TODO
  end

end