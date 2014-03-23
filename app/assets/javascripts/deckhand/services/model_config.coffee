Deckhand.app.factory "ModelConfig", ['modelConfigData', (modelConfigData) ->
  field = (model, name, relation) ->
    return null unless modelConfigData[model]
    if relation
      className = modelConfigData[model][relation].class_name
      return null unless modelConfigData[className]
      modelConfigData[className][name]
    else
      modelConfigData[model][name]

  type = (model, name) ->
    f = field(model, name)
    (if f then f.type else null)

  tableFields = (model) ->
    modelConfig = modelConfigData[model]
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
