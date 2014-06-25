Deckhand.app.factory "FieldFormatter", [
  "ModelConfig"
  (ModelConfig) ->
    format = (item, attr, modifier) ->
      type = ModelConfig.type(item._model, attr)
      value = undefined
      if type is "relation" or item[attr]?._model
        obj = item[attr]
        value = (if obj then obj._label else "none")
      else
        value = item[attr]

      choices = item[attr + "_choices"]
      if choices
        value_from_choices = undefined
        for choice in choices
          value_from_choices = choice.value if choice.key == value
        value = value_from_choices || value

      value = value.replace(/\r\n|\r|\n/g, "<br/>") if modifier is "multiline"

      value

    substitute = (item, attr, string) ->
      value = format(item, attr)
      string.replace /:value/g, value

    {
      format: format
      substitute: substitute
    }
]
