var moment = require('moment'),
  angular = require('angular');

require('./lib/angular-resource');
require('./lib/angular-sanitize');
require('./lib/angular-animate');
require('./lib/angular-ui-bootstrap-0.10.0');
require('./lib/angular-ui-bootstrap-tpls-0.10.0');
require('./controllers');

var Deckhand = angular.module('Deckhand', ['ngResource', 'ngSanitize', 'ngAnimate', 'controllers'])

.factory('Search', ['$resource', function($resource) {
  return $resource(DeckhandGlobals.searchPath);
}])

.factory('Model', ['$resource', function($resource) {
  return $resource(DeckhandGlobals.showPath, null, {
    act: {method: 'PUT', url: DeckhandGlobals.showPath + '/act'}
  });
}])

.filter('humanTime', function() {
  return function(time) {
    return time ? moment(new Date(time)).fromNow() : 'never';
  }
})

.filter('pluralize', function() {
  return function(quantity) {
    return quantity == 1 ? '' : 's';
  }
})

.run(['$rootScope', function($rootScope) {
  // init stuff
}]);
