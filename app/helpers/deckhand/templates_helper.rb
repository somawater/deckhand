module Deckhand::TemplatesHelper

  def fields_to_show
    Deckhand.config.fields_to_show @model
  end

  def angular_binding(field, parent = 'item')
    if Deckhand.config.link?(@model, field)
      trusted_html do
        ng_click = "open(#{Deckhand.config.model_name_for(@model, field)}, '{{item.id}}')"
        content_tag :a, "{{#{parent}.#{field}._label}}", 'ng-click' => ng_click
      end
    else
      "{{#{parent}.#{field} | prettify}}"
    end
  end

  def trusted_html(&block)
    content_tag :div, '', 'ng-bind-html' => "raw('#{block.call}')"
  end

  def relations_to_tabulate
    [] # TODO
  end

end