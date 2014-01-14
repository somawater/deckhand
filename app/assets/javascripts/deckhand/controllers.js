angular.module('controllers', ['ui.bootstrap'])

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

.controller('CardsCtrl', ['$scope', '$sce', '$filter', '$modal', 'Model', function($scope, $sce, $filter, $modal, Model) {
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

  $scope.substitute = function(item, attr, string) {
    var value = $scope.value(item, attr);
    return string.replace(':value', value);
  };

  $scope.act = function(item, action, options) {
    if (!options) options = {confirm: true};

    if (options.form) {

      return;
    }

    // TODO: open some sort of dialog with the options listed
    if (!('confirm' in options) || confirm('Are you sure you want to do that?')) {
      Model.act({model: item._model, id: item.id, act: action, value: options.confirm}, function(newItem) {
        $scope.items.splice($scope.items.indexOf(item), 1, newItem);
        var result = newItem._result;
        if (result && result._model) {
          $scope.open(result._model, result.id);
        }
      })
    }
  };

}])
