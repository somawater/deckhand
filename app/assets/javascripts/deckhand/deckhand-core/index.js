var Dombars = require('dombars'),
  each = require('u.each'),
  timeago = require('timeago');

Dombars.registerHelper('humanTime', function(time) {
  return new Dombars.SafeString(timeago(new Date(time)));
});

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

  var templates = {},
    templateSizes = ['small', 'large'],
    searchInput,
    searchResults,
    cards;

  var createNode = function(model, size) {
    var fragment = templates[model.type][size](model);
    return fragment;
  };

  var compileModelTemplates = function(modelName) {
    templates[modelName] = {};
    each(templateSizes, function(size) {
      var element = document.getElementById('template-' + modelName + '-' + size);
      if (element) {
        templates[modelName][size] = Dombars.compile(element.innerHTML);
      }
    });
  };

  var setupAutocomplete = function() {
    searchInput.addEventListener('change', function(event) {
      searchResults.innerHTML = '';

      $.get('search', {term: searchInput.value}, function(resp) {
        each(resp, function(item) {
          var li = document.createElement('li');
          li.setAttribute('class', 'list-group-item');
          li.appendChild(createNode(item, 'small'));
          prepend(searchResults, li);
          storeData(li, item);
        })
      });
    });
  };

  return {
    init: function(modelNames) {
      each(modelNames, compileModelTemplates);

      searchInput = document.getElementById('search-input');
      searchResults = document.getElementById('search-results');
      cards = document.getElementById('cards');

      setupAutocomplete();

      searchResults.addEventListener('click', function(event) {
        if (event.target.tagName != 'LI') return;
        var item = fetchData(event.target);
        var card = createNode(item, 'large');
        prepend(cards, card);
      })
    },
  };
})();
