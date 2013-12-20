var moment = require('moment'),
  angular = require('angular');

require('./lib/angular-resource');

var Deckhand = angular.module('Deckhand', ['ngResource'])

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

.controller('CardsCtrl', ['$scope', 'Model', function($scope, Model) {
  $scope.items = [];

  $scope.add = function(item) {
    $scope.items.unshift(item);
  };

  $scope.open = function(model, id) {
    $scope.items.unshift(Model.get({model: model, id: id}));
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
