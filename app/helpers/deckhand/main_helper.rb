module Deckhand::MainHelper

  def deckhand_template(model, size, more_attrs = {})
    attrs = {
      type: 'text/ng-template',
      id: "#{model}/#{size}"
    }.merge(more_attrs)

    content_tag(:script, attrs) do
      yield
    end
  end

  def trusted_html(attr)
    content_tag :div, '', 'ng-bind-html' => "raw(#{attr})"
  end

end