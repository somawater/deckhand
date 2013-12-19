Dombars = require('dombars'),
  each = require('u.each'),
  moment = require('moment'),
  delegate = require('delegation'),
  matches = require('matches-selector'),
  ajax = require('component-ajax');

require('./content_helpers');

var getJson = function(url, data, success) {
  return ajax({url: url, dataType: 'json', data: data, success: success});
};

var storage = {};

storeData = function(node, data) {
  var key = Math.random().toString();
  storage[key] = data;
  node.dataset.storeKey = key;
}

fetchData = function(node) {
  var key = node.dataset.storeKey;
  return key ? storage[key] : nil;
}

var prepend = function(parent, child) {
  if (parent.children.length == 0) {
    parent.appendChild(child);
  } else {
    parent.insertBefore(child, parent.children[0]);
  }
}

window.Deckhand = (function() {

  var templates = {}, searchInput, searchResults, cards, searchPath, showPath;

  var createNode = function(model, size) {
    var fragment = templates[model.type][size](model);
    return fragment;
  };

  var compileTemplates = function() {
    var elements = document.querySelectorAll('[type="text/x-handlebars-template"][data-model][data-size]');
    elements = Array.prototype.slice.call(elements);
    each(elements, function(element) {
      var model = element.getAttribute('data-model'),
        size = element.getAttribute('data-size');

      if (matches(element, '[data-partial]')) {
        var partialName = model + '_' + size.replace('-', '_');
        Dombars.registerPartial(partialName, element.innerHTML);
      } else {
        if (!templates[model]) templates[model] = {};
        templates[model][size] = Dombars.compile(element.innerHTML);
      }
    });
  };

  var compilePartial = function(element) {
    var partialName = element.getAttribute('data-model') + '_' + element.getAttribute('data-size').replace('-', '_');
    Dombars.registerPartial(partialName, element.innerHTML);
  };

  var setupBehavior = function() {
    searchInput.addEventListener('change', function(event) {
      searchResults.innerHTML = '';

      getJson(searchPath, {term: searchInput.value}, function(items) {
        each(items, function(item) {
          var li = document.createElement('li');
          li.setAttribute('class', 'list-group-item');
          li.appendChild(createNode(item, 'search_result'));
          prepend(searchResults, li);
          storeData(li, item);
        })
      });
    });

    delegate(searchResults, 'click', 'li', function(event) {
      var item = fetchData(event.target);
      var card = createNode(item, 'card');
      prepend(cards, card);
    })

    delegate(cards, 'click', 'a[data-model][data-id]', function(event) {
      var params = {
        id: event.target.getAttribute('data-id'),
        model: event.target.getAttribute('data-model')
      };
      getJson(showPath, params, function(item) {
        var card = createNode(item, 'card');
        prepend(cards, card);
      })
    });
  };

  return {
    init: function(options) {
      searchPath = options.searchPath;
      showPath = options.showPath;

      searchInput = document.getElementById('search-input');
      searchResults = document.getElementById('search-results');
      cards = document.getElementById('cards');

      compileTemplates();
      setupBehavior();
    }
  };
})();
