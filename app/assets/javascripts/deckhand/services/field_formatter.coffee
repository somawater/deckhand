Deckhand.app.factory "FieldFormatter", [
  "ModelConfig"
  (ModelConfig) ->
    format = (item, attr, modifier) ->
      type = ModelConfig.type(item._model, attr)
      value = undefined
      if type is "relation"
        obj = item[attr]
        value = (if obj then obj._label else "none")
      else
        value = item[attr]
      value = value.replace(/\r\n|\r|\n/g, "<br/>") if modifier is "multiline"
      value

    substitute = (item, attr, string) ->
      value = format(item, attr)
      string.replace ":value", value

    {
      format: format
      substitute: substitute
    }
]
