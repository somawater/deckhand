window.extend = require("extend")
window.slice = require("slice-keys")

moment = require("moment")

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

require "./controllers/index.coffee"
require "./services/index.coffee"
require "./directives/index.coffee"

Deckhand.app.filter "readableMethodName", ->
  (name) ->
    name.replace /_/g, " "
