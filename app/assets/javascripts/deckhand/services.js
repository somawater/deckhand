Deckhand.factory('Search', ['$resource', function($resource) {
  return $resource(DeckhandGlobals.searchPath);
}])

.factory('Model', ['$resource', function($resource) {
  return $resource(DeckhandGlobals.showPath, null, {
    act: {method: 'PUT', url: DeckhandGlobals.showPath + '/act'},
    getFormData: {method: 'GET', url: DeckhandGlobals.showPath + '/form'},
    update: {method: 'PUT', url: DeckhandGlobals.showPath}
  });
}])

.factory('ModelStore', [function() {

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

  var find = function(model, id) {
    return (store[model] ? store[model][id] : null);
  };

  return {
    find: find,
    register: register
  };

}])

.factory('FieldFormatter', ['$filter', function($filter) {
  var format = function(item, attr, modifier) {
    var fieldTypes = DeckhandGlobals.fieldTypes[item._model];
    var value;

    if (!fieldTypes) {
      value = item[attr];
    } else if (fieldTypes[attr] == 'relation') {
      obj = item[attr];
      value = (obj ? obj._label : 'none');
    } else {
      value = item[attr];
    }

    if (modifier == 'multiline') {
      value = value.replace(/\n/, '<br/>');
    }

    return value;
  };

  var substitute = function(item, attr, string) {
    var value = format(item, attr);
    return string.replace(':value', value);
  };

  return {format: format, substitute: substitute};
}]);
