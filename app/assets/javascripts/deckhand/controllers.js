var qs = require('querystring'),
  extend = require('extend'),
  union = require('./lib/union');

// TODO fancier error handling
var handleError = function(response) {
  alert('Error: ' + response.data.error);
};

angular.module('controllers', ['ui.bootstrap'])

.controller('RootCtrl', ['$rootScope', 'Model', function($rootScope, Model) {

  $rootScope.cards = [];
  window.itemEntries = {};

  var focusCard = function(index) {
    var event = new CustomEvent('focusItem', {detail: {index: index}});
    document.getElementById('cards').dispatchEvent(event);
  };

  var findEntry = function(model, id) {
    return (itemEntries[model] ? itemEntries[model][id] : null);
  };

  var register = function(item) {
    var model = item._model, id = item.id;

    if (!itemEntries[model])
      itemEntries[model] = {};

    if (!itemEntries[model][id])
      itemEntries[model][id] = {card: false};

    var entry = itemEntries[model][id];

    if (entry.item) {
      extend(true, entry.item, item);
    } else {
      entry.item = item;
    }

    Object.keys(item).forEach(function(field) {
      var type = DeckhandGlobals.fieldTypes[item._model][field];
      if (type == 'table') {
        item[field].forEach(register);
      } else if (type == 'relation' && item[field] && item[field]._model) {
        register(item[field]);
      }
    });

    return entry;
  };

  $rootScope.showCard = function(model, id) {
    var entry = findEntry(model, id);

    if (entry && entry.card) {
      focusCard($rootScope.cards.indexOf(entry.item));
    } else {
      Model.get({model: model, id: id}, function(item) {
        var entry = register(item, true);
        entry.card = true;
        $rootScope.cards.unshift(entry.item);
        focusCard(0);
      });
    }
  };

  $rootScope.removeCard = function(item) {
    $rootScope.cards.splice($rootScope.cards.indexOf(item), 1);
    findEntry(item._model, item.id).card = false;
  };

  $rootScope.refreshItem = function(newItem) {
    var entry = register(newItem);
    if (entry.card) {
      var index = $rootScope.cards.indexOf(entry.item);
      $rootScope.cards.splice(index, 1, entry.item); // trigger animation
    }
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

.controller('ModalFormCtrl', ['$scope', '$modalInstance', '$upload', 'Model', 'context',
  function($scope, $modalInstance, $upload, Model, context) {

  $scope.item = context.item;
  $scope.title = context.title;
  $scope.form = {};
  $scope.choicesForSelect = {};

  Model.getFormData(extend({id: $scope.item.id}, context.formParams), function(form) {
    Object.keys(form).forEach(function(key) {
      if (key.charAt(0) != '$') {
        var data = form[key];
        $scope.form[key] = data.value;
        if (data.choices) {
          // FIXME this "form." prefix is weird
          $scope.choicesForSelect['form.' + key] = data.choices;
        }
      }
    });
  });

  $scope.cancel = function() {
    $modalInstance.dismiss('cancel');
  };

  $scope.files = {};

  $scope.onFileSelect = function($files, name) {
    $scope.files[name.replace(/(\.(.*))$/, '[$2]')] = $files[0];
  }

  $scope.submit = function() {
    $scope.error = null;

    var params;
    if (context.verb == 'update') {
      params = {url: DeckhandGlobals.showPath, method: 'PUT'};
    } else if (context.verb == 'act') {
      params = {url: DeckhandGlobals.showPath + '/act', method: 'PUT'};
    }

    var filenames = Object.keys($scope.files);
    var files = filenames.map(function(name) { return $scope.files[name] });

    extend(params, {
      fileFormDataName: filenames,
      file: files,
      data: {
        id: $scope.item.id,
        non_file_params: extend({form: $scope.form}, context.formParams)
      },
    });

    $upload.upload(params).success(function(response) {
      $modalInstance.close(response);
    }).error(function(response) {
      $scope.error = response.error;
    });
  };

}])

.controller('CardCtrl', ['$scope', '$filter', '$modal', 'Model', function($scope, $filter, $modal, Model) {

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

  var processResponse = function(response) {
    response.changed.forEach(function(item) {
      $scope.refreshItem(item);
    })

    var result = response.result;
    if (result && result._model) {
      $scope.showCard(result._model, result.id);
    }
  };

  $scope.act = function(item, action, options) {
    if (!options) options = {confirm: 'Are you sure?'};

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

      modalInstance.result.then(processResponse);
      return;
    }

    if (!('confirm' in options) || confirm(options.confirm)) {
      Model.act({model: item._model, id: item.id, act: action}, processResponse);
    }
  };

  $scope.edit = function(name, options) {
    if (options == true) options = {};

    var item = (options.nested ? $scope.item[name] : $scope.item),
      formParams = {type: 'edit', model: item._model},
      url;

    if (name && !options.nested) { // single-field editing
      formParams.edit_fields = [name];
      url = DeckhandGlobals.templatePath + '?' + qs.stringify(formParams);

      // this is a workaround for an issue with Angular where it doesn't
      // stringify parameters the same way that Node's querystring does,
      // e.g. http://stackoverflow.com/questions/18318714/angularjs-resource-cannot-pass-array-as-one-of-the-parameters
      formParams['edit_fields[]'] = formParams.edit_fields;
      delete formParams.edit_fields;

    } else { // all editable fields at once
      url = DeckhandGlobals.templatePath + '?' + qs.stringify(formParams);
    }

    var modalInstance = $modal.open({
      templateUrl: url,
      controller: 'ModalFormCtrl',
      resolve: {
        context: function() {
          return {item: item, title: 'edit', formParams: formParams, verb: 'update'};
        }
      }
    });

    modalInstance.result.then(processResponse);
  };

  $scope.refresh = function() {
    Model.get({model: $scope.item._model, id: $scope.item.id}, function(newItem) {
      $scope.refreshItem(newItem);
    });
  }

}]);