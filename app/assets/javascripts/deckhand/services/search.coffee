Deckhand.app.factory "Search", [
  "$resource"
  ($resource) -> return $resource(Deckhand.searchPath)
]
