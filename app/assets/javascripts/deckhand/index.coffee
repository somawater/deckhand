window.extend = require("extend")
window.slice = require("slice-keys")

moment = require("moment")
scroll = require("scroll")

require "angular"
require "./lib/angular-resource"
require "./lib/angular-sanitize"
require "./lib/angular-animate"
require "./lib/angular-ui-bootstrap-0.10.0"
require "./lib/angular-ui-bootstrap-tpls-0.10.0"
require "./lib/angular-file-upload"

Deckhand.app = angular.module 'Deckhand', [
  'ngResource'
  'ngSanitize'
  'ngAnimate'
  'angularFileUpload'
  'ui.bootstrap'
]

require "./controllers"
require "./services"
require "./directives"

Deckhand.app.filter 'humanTime', ->
  (time) ->
    if time then moment(new Date(time)).fromNow() else "never"

.filter 'pluralize', ->
  (quantity) ->
    if quantity is 1 then "" else "s"

.filter "readableMethodName", ->
  (name) ->
    name.replace /_/g, " "

Deckhand.app.run [
  "$rootScope"
  ($rootScope) ->
    scrollOptions = {duration: 800, ease: 'outQuint'}

    document.getElementById("cards").addEventListener "focusItem", (event) ->
      index = event.detail.index + 1 # nth-child is 1-indexed

      if index is 1
        scroll.top document.documentElement, 0, scrollOptions
      else
        selector = "#cards > div:nth-child(#{index})"
        element = document.querySelector(selector)
        scroll.top document.documentElement, element.offsetTop, scrollOptions

]