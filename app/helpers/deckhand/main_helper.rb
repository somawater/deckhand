module Deckhand::MainHelper

  def deckhand_template(model, size, more_attrs = {})
    attrs = {
      type: 'text/x-handlebars-template',
      :'data-model' => model,
      :'data-size' => size
    }.merge(more_attrs)

    content_tag(:script, attrs) do
      yield
    end
  end

  def deckhand_partial(model, size)
    deckhand_script_tag(model, size, :'data-partial' => 'true')
  end

end