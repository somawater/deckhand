Deckhand.app.factory "Model", [
  "$resource"
  ($resource) ->
    return $resource(Deckhand.showPath, null,
      act:
        method: "PUT"
        url: Deckhand.showPath + "/act"

      getFormData:
        method: "GET"
        url: Deckhand.showPath + "/form"

      update:
        method: "PUT"
        url: Deckhand.showPath
    )
]
