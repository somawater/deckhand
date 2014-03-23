# We expose jQuery to global in order for angular to use it.
# We need jQuery to be used instead of jqLite because we want DOM
# inserts to eval script tags, so that javascript gets executed
window.$ = window.jQuery = require 'jquery'

require "./lib/angular"
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

Deckhand.app.value 'modelConfigData', Deckhand.models

require "./controllers/index.coffee"
require "./services/index.coffee"
require "./directives/index.coffee"

Deckhand.app.filter "readableMethodName", ->
  (name) ->
    name.replace /_/g, " "
