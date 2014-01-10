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
    $scope.noResults = false;
    $scope.results = Search.query({term: $scope.term}, function(results) {
      if (results.length == 0) $scope.noResults = true;
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

.controller('CardsCtrl', ['$scope', '$sce', '$filter', 'Model', function($scope, $sce, $filter, Model) {
  $scope.items = [];

  $scope.add = function(item) {
    $scope.items.unshift(item);
  };

  $scope.template = function(item) {
    return DeckhandGlobals.templatePath + '?model=' + item._model;
  };

  $scope.open = function(model, id) {
    if (!id) return;
    Model.get({model: model, id: id}, function(item) {
      $scope.items.unshift(item);
    });
  };

  $scope.close = function(item) {
    $scope.items.splice($scope.items.indexOf(item), 1);
  };

  $scope.raw = function(value) {
    return $sce.trustAsHtml(value);
  };

  $scope.value = function(item, attr) {
    var fieldTypes = DeckhandGlobals.fieldTypes[item._model];
    var value;
    if (!fieldTypes) {
      value = item[attr];
    } else if (fieldTypes[attr] == 'time') {
      value = $filter('humanTime')(item[attr]);
    } else if (fieldTypes[attr] == 'relation') {
      obj = item[attr];
      value = (obj ? obj._label : 'none');
    } else {
      value = item[attr];
    }
    return value;
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
