moment = require('moment')

Deckhand.app.directive 'dhTime', ->
  link = (scope, element, attrs) ->
    scope.$watch 'time', (value) ->
      if value
        time = moment(new Date(value))
        scope.shortTime = time.fromNow()
        element.attr 'title', time.format('MMM Do, YYYY h:mm:ss a Z')
      else
        scope.shortTime = 'never'

  {
    link: link
    scope: {time: '@'}
    restrict: 'E'
    replace: true
    template: '<span title="{{fullTime}}">{{shortTime}}</span>'
  }
