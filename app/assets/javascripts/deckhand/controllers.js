var qs = require('querystring'),
  extend = require('extend');

// TODO fancier error handling
var handleError = function(response) {
  alert('Error: ' + response.data.error);
};

angular.module('controllers', ['ui.bootstrap'])

.controller('RootCtrl', ['$rootScope', 'Model', function($rootScope, Model) {

  $rootScope.cards = [];
  var openedItems = {};

  var focusCard = function(index) {
    var event = new CustomEvent('focusItem', {detail: {index: index}});
    document.getElementById('cards').dispatchEvent(event);
  }

  $rootScope.showCard = function(model, id) {
    var openedItem = (openedItems[model] ? openedItems[model][id] : null);

    if (openedItem) {
      focusCard($rootScope.cards.indexOf(openedItem));
    } else {
      Model.get({model: model, id: id}, function(item) {
        if (!openedItems[model]) openedItems[model] = {};
        openedItems[model][id] = item;
        $rootScope.cards.unshift(item);
        focusCard(0);
      });
    }
  };

  $rootScope.removeCard = function(item) {
    $rootScope.cards.splice($rootScope.cards.indexOf(item), 1);
    delete openedItems[item._model][item.id];
  };

  $rootScope.replaceCard = function(item, newItem) {
    $rootScope.cards.splice($rootScope.cards.indexOf(item), 1, newItem);
    delete openedItems[item._model][item.id];
    openedItems[newItem._model][newItem.id] = newItem;
  };

  $rootScope.cardTemplate = function(item) {
    return DeckhandGlobals.templatePath + '?' + qs.stringify({model: item._model, type: 'card'});
  };

}])

.controller('SearchCtrl', ['$scope', 'Search', 'Model', function($scope, Search, Model) {

  $scope.search = function() {
    $scope.noResults = false;
    $scope.results = Search.query({term: $scope.term}, function(results) {
      if (results.length == 0) $scope.noResults = true;
    });
  };

  $scope.reset = function() {
    $scope.term = null;
    $scope.results = [];
    $scope.noResults = false;
  };

}])

.controller('ModalFormCtrl', ['$scope', '$modalInstance', 'Model', 'context', function($scope, $modalInstance, Model, context) {

  var inputs = [];

  $scope.item = context.item;
  $scope.title = context.title;
  $scope.form = {};

  Model.form(extend({id: $scope.item.id}, context.formParams), function(form) {
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
    $scope.error = null;
    var data = extend({form: $scope.form, id: $scope.item.id}, context.formParams);

    Model[context.verb](data, function(newItem) {
      $modalInstance.close(newItem);
    }, function(response) {
      $scope.error = response.data.error;
    });
  };

}])

.controller('CardCtrl', ['$scope', '$sce', '$filter', '$modal', 'Model', function($scope, $sce, $filter, $modal, Model) {

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
    $scope.replaceCard(item, newItem);
    var result = newItem._result;
    if (result && result._model) {
      $scope.showCard(result._model, result.id);
    }
  };

  $scope.act = function(item, action, options) {
    if (!options) options = {confirm: true};

    if (options.form) {
      var formParams = {model: item._model, act: action, type: 'action'};
      var url = DeckhandGlobals.templatePath + '?' + qs.stringify(formParams);
      var modalInstance = $modal.open({
        templateUrl: url,
        controller: 'ModalFormCtrl',
        resolve: {
          context: function() {
            return {
              item: item,
              title: $filter('readableMethodName')(action),
              formParams: formParams,
              verb: 'act'
            };
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

  $scope.edit = function(name) {
    var formParams = {model: $scope.item._model, id: $scope.item.id, type: 'edit'}, url;

    if (name) {
      formParams.edit_fields = [name];
      url = DeckhandGlobals.templatePath + '?' + qs.stringify(formParams);

      // this is a workaround for an issue with Angular where it doesn't
      // stringify parameters the same way that Node's querystring does,
      // e.g. http://stackoverflow.com/questions/18318714/angularjs-resource-cannot-pass-array-as-one-of-the-parameters
      formParams['edit_fields[]'] = formParams.edit_fields;
      delete formParams.edit_fields;
    } else {
      url = DeckhandGlobals.templatePath + '?' + qs.stringify(formParams);
    }

    var modalInstance = $modal.open({
      templateUrl: url,
      controller: 'ModalFormCtrl',
      resolve: {
        context: function() {
          return {item: $scope.item, title: 'edit', formParams: formParams, verb: 'update'};
        }
      }
    });

    modalInstance.result.then(function(newItem) {
      refreshItem($scope.item, newItem);
    });
  };

}]);