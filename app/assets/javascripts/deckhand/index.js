var moment = require('moment'),
  angular = require('angular');

require('./lib/angular-resource');
require('./lib/angular-sanitize');

var Deckhand = angular.module('Deckhand', ['ngResource', 'ngSanitize'])

.factory('Search', ['$resource', function($resource) {
  return $resource(DeckhandGlobals.searchPath);
}])

.factory('Model', ['$resource', function($resource) {
  return $resource(DeckhandGlobals.showPath);
}])

.controller('SearchCtrl', ['$scope', 'Search', function($scope, Search) {
  $scope.search = function() {
    $scope.results = Search.query({term: $scope.term});
  };

  $scope.template = function(item) {
    return item.type + '/search_result';
  };

  $scope.open = function(item) {
    // HMMM what's that smell
    var cardCtrl = angular.element(document.getElementById('cards')).scope();
    cardCtrl.add(item);
  };

}])

.controller('CardsCtrl', ['$scope', '$sce', 'Model', function($scope, $sce, Model) {
  $scope.items = [];

  $scope.add = function(item) {
    $scope.items.unshift(item);
  };

  $scope.template = function(item) {
    return item.type + '/card';
  };

  $scope.open = function(model, id) {
    Model.get({model: model, id: id}, function(item) {
      $scope.items.unshift(item);
    });
  };

  $scope.raw = function(value) {
    return $sce.trustAsHtml(value);
  };

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
