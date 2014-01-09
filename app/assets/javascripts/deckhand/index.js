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

.controller('SearchCtrl', ['$scope', 'Search', 'Model', function($scope, Search, Model) {

  $scope.search = function() {
    $scope.results = Search.query({term: $scope.term}, function(results) {
      if (results.length == 0)
        $scope.noResults = true;
    });
  };

  $scope.open = function(result) {
    Model.get({model: result._model, id: result.id}, function(item) {
      // HMMM what's that smell? there's got to be a better way to do this
      var cardCtrl = angular.element(document.getElementById('cards')).scope();
      cardCtrl.add(item);
    })
  };

  $scope.reset = function() {
    $scope.term = null;
    $scope.results = [];
    $scope.noResults = false;
  };

}])

.controller('CardsCtrl', ['$scope', '$sce', 'Model', function($scope, $sce, Model) {
  $scope.items = [];

  $scope.add = function(item) {
    $scope.items.unshift(item);
  };

  $scope.template = function(item) {
    return item._model + '/card';
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
