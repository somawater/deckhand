scroll = require("scroll")

Deckhand.app.directive 'dhScrollTo', ->
  (scope, element, attrs) ->
    scrollToElement = ->
      scroll.top document.body, element[0].offsetTop,
        duration: 800
        ease: 'outQuint'

    # Perform a scroll right now, so that we scroll down to this new item when
    # it appears in the DOM
    scrollToElement()

    # Then scroll to this item whenever the event triggers
    scope.$on attrs.dhScrollTo, (event, item) ->
      if (item == scope.item)
        scrollToElement()
        event.preventDefault()
