// TODO fancier error handling
var handleError = function(response) {
  alert('Error: ' + response.data.error);
};

angular.module('controllers', ['ui.bootstrap'])

.controller('RootCtrl', ['$scope', '$rootScope', function($scope, $rootScope) {

  $rootScope.rootCtrl = $scope;
  $rootScope.cards = [];
  var openedItems = {};

  var matchingOpenedItem = function(item) {
    if (!openedItems[item._model]) return false;
    return openedItems[item._model][item.id];
  }

  $scope.openCard = function(item) {
    var openItem = matchingOpenedItem(item), event;

    if (openItem) {
      event = new CustomEvent('focusItem', {detail: {index: $rootScope.cards.indexOf(openItem)}});
    } else {
      if (!openedItems[item._model]) openedItems[item._model] = {};
      openedItems[item._model][item.id] = item;
      $rootScope.cards.unshift(item);
      event = new CustomEvent('focusItem', {detail: {index: 0}});
    }

    document.getElementById('cards').dispatchEvent(event);
  };

  $scope.removeCard = function(item) {
    $rootScope.cards.splice($rootScope.cards.indexOf(item), 1);
    delete openedItems[item._model][item.id];
  };

  $scope.replaceCard = function(item, newItem) {
    $rootScope.cards.splice($rootScope.cards.indexOf(item), 1, newItem);
  };

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
      $scope.rootCtrl.openCard(item);
    })
  };

  $scope.reset = function() {
    $scope.term = null;
    $scope.results = [];
    $scope.noResults = false;
  };

}])

.controller('ActionFormCtrl', ['$scope', '$modalInstance', 'Model', 'context', function($scope, $modalInstance, Model, context) {

  var item = context.item, action = context.action, inputs = [];

  $scope.item = item;
  $scope.action = action;
  $scope.form = {};

  Model.form({model: item._model, act: action, id: item.id}, function(form) {
    Object.keys(form).forEach(function(key) {
      if (key.charAt(0) != '$') {
        $scope.form[key] = form[key];
        inputs.push(key);
      }
    });
  });

  $scope.cancel = function() {
    $modalInstance.dismiss('cancel');
  };

  $scope.submit = function() {
    var data = {model: item._model, id: item.id, act: action, form: $scope.form};
    $scope.error = null;
    Model.act(data, function(newItem) {
      $modalInstance.close(newItem);
    }, function(response) {
      $scope.error = response.data.error;
    });
  };

}])

.controller('CardsCtrl', ['$scope', '$sce', '$filter', '$modal', 'Model', function($scope, $sce, $filter, $modal, Model) {

  $scope.template = function(item) {
    return DeckhandGlobals.templatePath + '?model=' + item._model;
  };

  $scope.open = function(model, id) {
    if (!id) return;
    Model.get({model: model, id: id}, function(item) {
      $scope.rootCtrl.openCard(item);
    });
  };

  $scope.close = function(item) {
    $scope.rootCtrl.removeCard(item);
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

  var refreshItem = function(item, newItem) {
    $scope.rootCtrl.replaceCard(item, newItem);
    var result = newItem._result;
    if (result && result._model) {
      $scope.open(result._model, result.id);
    }
  };

  $scope.act = function(item, action, options) {
    if (!options) options = {confirm: true};

    if (options.form) {
      var url = DeckhandGlobals.templatePath + '?model=' + item._model + '&act=' + action + '&id=' + item.id;
      var modalInstance = $modal.open({
        templateUrl: url,
        controller: 'ActionFormCtrl',
        resolve: {
          context: function() {
            return {item: item, action: action};
          }
        }
      });

      modalInstance.result.then(function(newItem) {
        refreshItem(item, newItem);
      });
      return;
    }

    if (!('confirm' in options) || confirm('Are you sure you want to do that?')) {
      Model.act({model: item._model, id: item.id, act: action}, function(newItem) {
        refreshItem(item, newItem);
      });
    }
  };

  $scope.updateAttribute = function(item, name) {
    var promptLabel = "Change " + name + " for " + item._label + ':';
    var newValue = prompt(promptLabel, item[name]);

    if (newValue != null) {
      var data = {model: item._model, id: item.id, attributes: {}};
      data.attributes[name] = newValue;

      Model.update(data, function(newItem) {
        refreshItem(item, newItem);
      }, handleError);
    }
  };

}]);