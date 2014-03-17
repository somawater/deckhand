# Angular-UI Bootstrap alert service for Angular.js
# https://coderwall.com/p/r_bvhg
Deckhand.app.factory "AlertService", [
  "$rootScope", "$timeout"
  ($rootScope, $timeout) ->
    AlertService = undefined
    $rootScope.alerts = []

    add = (type, message) ->
      return if message is `undefined` or not message?
      alert =
        type: type
        message: message
        close: -> AlertService.close this
      $rootScope.alerts.push alert
      alert

    close = (alert) ->
      closeIndex $rootScope.alerts.indexOf(alert)

    closeIndex = (index) ->
      return if index < 0
      $rootScope.alerts.splice index, 1

    clear = ->
      $rootScope.alerts.length = 0

    return AlertService =
      add: add
      close: close
      closeIndex: closeIndex
      clear: clear
]
