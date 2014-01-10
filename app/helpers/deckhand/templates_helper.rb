module Deckhand::TemplatesHelper

  def fields_to_show
    Deckhand.config.fields_to_show @model
  end

  def angular_binding(field, options = {})
    parent = options[:parent] || 'item'

    if Deckhand.config.link?(@model, field)
      ng_click = "open('#{Deckhand.config.model_name_for(@model, field)}', item.#{field}.id)"
      content_tag :a, "{{#{parent}.#{field}._label}}", 'ng-click' => ng_click
    elsif options[:html]
      trusted_html "{{#{parent}.#{field}}}"
    else
      "{{#{parent}.#{field} | prettify}}"
    end
  end

  def trusted_html(string = nil, &block)
    content_tag :div, '', 'ng-bind-html' => "raw('#{string || block.call}')"
  end

  def relations_to_tabulate
    [] # TODO
  end

end