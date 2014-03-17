scroll = require("scroll")

Deckhand.app.directive 'dhScrollTo', ->
  (scope, element, attrs) ->
    scope.$on attrs.dhScrollTo, (event, item) ->
      if (item == scope.item)
        scroll.top document.body, element[0].offsetTop,
          duration: 800
          ease: 'outQuint'
        event.preventDefault()
