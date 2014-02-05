Deckhand.app.factory('Search', ['$resource', function($resource) {
  return $resource(Deckhand.searchPath);
}])

// Angular-UI Bootstrap alert service for Angular.js
// https://coderwall.com/p/r_bvhg
.factory('AlertService', ['$rootScope', function($rootScope) {

  var AlertService;

  $rootScope.alerts = [];

  var add = function(type, message) {
    if (message === undefined || message == null) return;
    $rootScope.alerts.push({type: type, message: message, close: function() {
        AlertService.close(this);
      }
    });
  }

  var close = function(alert) {
    this.closeIndex($rootScope.alerts.indexOf(alert));
  }

  var closeIndex = function(index) {
    $rootScope.alerts.splice(index, 1);
  }

  var clear = function() {
    $rootScope.alerts = [];
  }

  return AlertService = {
    add: add,
    close: close,
    closeIndex: closeIndex,
    clear: clear
  };

}])

.factory('Model', ['$resource', function($resource) {
  return $resource(Deckhand.showPath, null, {
    act: {method: 'PUT', url: Deckhand.showPath + '/act'},
    getFormData: {method: 'GET', url: Deckhand.showPath + '/form'},
    update: {method: 'PUT', url: Deckhand.showPath}
  });
}])

.factory('ModelStore', ['ModelConfig', function(ModelConfig) {

  window.store = {};

  var register = function(item) {
    var model = item._model, id = item.id;

    if (!store[model])
      store[model] = {};

    if (!store[model][id])
      store[model][id] = {card: false};

    var entry = store[model][id];

    if (entry.item) {
      extend(true, entry.item, item);
    } else {
      entry.item = item;
    }

    Object.keys(item).forEach(function(name) {
      var field = ModelConfig.field(item._model, name);
      if (!field) return;

      if (field.table) {
        item[name].forEach(register);
      } else if (field.type == 'relation' && item[name] && item[name]._model) {
        register(item[name]);
      }
    });

    return entry;
  };

  var find = function(model, id) {
    return (store[model] ? store[model][id] : null);
  };

  return {
    find: find,
    register: register
  };

}])

.factory('FieldFormatter', ['ModelConfig', function(ModelConfig) {
  var format = function(item, attr, modifier) {
    var type = ModelConfig.type(item._model, attr);
    var value;

    if (type == 'relation') {
      obj = item[attr];
      value = (obj ? obj._label : 'none');
    } else {
      value = item[attr];
    }

    if (modifier == 'multiline') {
      value = value.replace(/\r\n|\r|\n/g, '<br/>');
    }

    return value;
  };

  var substitute = function(item, attr, string) {
    var value = format(item, attr);
    return string.replace(':value', value);
  };

  return {format: format, substitute: substitute};
}])

.factory('ModelConfig', [function() {

  var field = function(model, name) {
    if (!Deckhand.models[model]) return null;
    return Deckhand.models[model][name];
  }

  var type = function(model, name) {
    var f = field(model, name);
    return (f ? f.type : null);
  };

  var tableFields = function(model) {
    var modelConfig = Deckhand.models[model];
    if (!modelConfig) return [];
    return Object.keys(modelConfig).filter(function(name) {
      return modelConfig.hasOwnProperty(name);
    }).map(function(name) {
      return modelConfig[name];
    });
  };

  return {field: field, type: type, tableFields: tableFields};
}]);

