var qs = require('querystring'), union = require('./lib/union');

Deckhand.controller('RootCtrl', ['$rootScope', 'Model', 'ModelStore',
  function($rootScope, Model, ModelStore) {

  $rootScope.cards = [];
  window.itemEntries = {};

  var focusCard = function(index) {
    var event = new CustomEvent('focusItem', {detail: {index: index}});
    document.getElementById('cards').dispatchEvent(event);
  };

  $rootScope.showCard = function(model, id) {
    if (!id) return;

    var entry = ModelStore.find(model, id);

    if (entry && entry.card) {
      focusCard($rootScope.cards.indexOf(entry.item));
    } else {
      Model.get({model: model, id: id}, function(item) {
        var entry = ModelStore.register(item);
        entry.card = true;
        $rootScope.cards.unshift(entry.item);
        focusCard(0);
      });
    }
  };

  $rootScope.removeCard = function(item) {
    $rootScope.cards.splice($rootScope.cards.indexOf(item), 1);
    ModelStore.find(item._model, item.id).card = false;
  };

  $rootScope.refreshItem = function(newItem) {
    var entry = ModelStore.register(newItem);
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

.controller('ModalFormCtrl', ['$scope', '$q', '$modalInstance', '$upload', 'Model', 'context', 'Search',
  function($scope, $q, $modalInstance, $upload, Model, context, Search) {

  $scope.item = context.item;
  $scope.form = {};
  $scope.choicesForSelect = {};

  Model.getFormData(extend({id: $scope.item.id}, context.formParams), function(form) {
    $scope.title = form.title || context.title;
    $scope.prompt = form.prompt;

    Object.keys(form.values).forEach(function(key) {
      if (key.charAt(0) != '$') {
        var data = form.values[key];
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

    // for typeahead selections, send only the instance's id to the server
    var formData = {};
    Object.keys($scope.form).forEach(function(key) {
      var value = $scope.form[key];
      formData[key] = (value && value.id ? value.id : value);
    })

    extend(params, {
      fileFormDataName: filenames,
      file: files,
      data: {
        id: $scope.item.id,
        non_file_params: extend({form: formData}, context.formParams)
      }
    });

    $upload.upload(params).success(function(response) {
      $modalInstance.close(response);
    }).error(function(response) {
      $scope.error = response.error;
    });
  };

  $scope.search = function(val, model) {
    return Search.query({term: val, model: model}).$promise;
  };

}])

.controller('CardCtrl', ['$scope', '$filter', '$modal', 'Model', 'ModelStore', 'FieldFormatter', 'AlertService',
  function($scope, $filter, $modal, Model, ModelStore, FieldFormatter, AlertService) {

  $scope.collapse = {};
  $scope.lazyLoad = {};

  $scope.init = function(item) {
    var fieldTypes = DeckhandGlobals.fieldTypes[item._model];
    Object.keys(fieldTypes).forEach(function(name) {
      if (fieldTypes[name] == 'lazy_table') {
        $scope.collapse[name] = true;
        $scope.lazyLoad[name] = true;
      } else if (fieldTypes[name] == 'table' && item[name].length == 0) {
        $scope.collapse[name] = true;
      }
    })
  };

  $scope.toggleTable = function(name) {
    if ($scope.lazyLoad[name]) {
      var params = {model: $scope.item._model, id: $scope.item.id, eager_load: 1, fields: name};
      Model.get(params, function(item) {
        ModelStore.register(item);
        $scope.lazyLoad[name] = false;
        $scope.collapse[name] = false;
      })
    } else {
      $scope.collapse[name] = !$scope.collapse[name];
    }
  };

  $scope.format = FieldFormatter.format;
  $scope.substitute = FieldFormatter.substitute;

  var processResponse = function(response) {
    AlertService.add('success', response.success);
    AlertService.add('warning', response.warning);
    AlertService.add('info', response.info);

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
              title: item._label + ": " + $filter('readableMethodName')(action),
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
    if (options == true || !options) options = {};

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
  };

}]);