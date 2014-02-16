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
require "./lib/angular-ui-utils-0.1.1"
require "./lib/angular-ui-utils-ieshiv-0.1.1"

Deckhand.app = angular.module 'Deckhand', [
  'ngResource'
  'ngSanitize'
  'ngAnimate'
  'angularFileUpload'
  'ui.bootstrap'
  'ui.utils'
]

require "./controllers"
require "./services"
require "./directives"

Deckhand.app.filter "readableMethodName", ->
  (name) ->
    name.replace /_/g, " "
