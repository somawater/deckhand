Dombars = require('dombars'),
  each = require('u.each'),
  moment = require('moment');

Dombars.registerHelper('humanTime', function(time) {
  return time ? moment(new Date(time)).fromNow() : 'never';
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
    searchInput, searchResults, cards;

  var createNode = function(model, size) {
    var fragment = templates[model.type][size](model);
    return fragment;
  };

  var compileModelTemplate = function(modelName) {
    templates[modelName] = {};
    each(templateSizes, function(size) {
      var selector = '[type="text/x-handlebars-template"][data-model="'+modelName+'"][data-size="'+size+'"]';
      var element = document.querySelector(selector);
      if (element) {
        templates[modelName][size] = Dombars.compile(element.innerHTML);
      }
    });
  };

  var compilePartial = function(element) {
    var partialName = element.getAttribute('data-model') + '_' + element.getAttribute('data-size').replace('-', '_');
    Dombars.registerPartial(partialName, element.innerHTML);
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
      each(modelNames, compileModelTemplate);
      partials = document.querySelectorAll('[type="text/x-handlebars-template"][data-partial]');
      each(Array.prototype.slice.call(partials), compilePartial);

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
