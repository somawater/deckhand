Deckhand.app.factory "ModelConfig", [->
  field = (model, name, relation) ->
    return null unless Deckhand.models[model]
    if relation
      className = Deckhand.models[model][relation].class_name
      return null unless Deckhand.models[className]
      Deckhand.models[className][name]
    else
      Deckhand.models[model][name]

  type = (model, name) ->
    f = field(model, name)
    (if f then f.type else null)

  tableFields = (model) ->
    modelConfig = Deckhand.models[model]
    return [] unless modelConfig
    Object.keys(modelConfig).filter((name) ->
      modelConfig.hasOwnProperty name
    ).map (name) -> modelConfig[name]

  {
    field: field
    type: type
    tableFields: tableFields
  }
]
