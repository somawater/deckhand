//= require jquery
//= require jquery.ui.autocomplete
//= require deckhand/lib/handlebars-v1.1.2

window.Deckhand = (function() {

  var templates = {}, templateSizes = ['small', 'large'];

  var compileModelTemplates = function(modelName) {
    templates[modelName] = {};
    $.each(templateSizes, function(i, size) {
      var element = document.getElementById('template-' + modelName + '-' + size);
      if (element) {
        templates[modelName][size] = Handlebars.compile(element.innerHTML);
      }
    });
  };

  return {
    render: function(model, size) {
      return templates[model.type][size](model);
    },
    init: function(modelNames) {
      $.each(modelNames, function(i, n) { compileModelTemplates(n); });
    },
  };
})();

$(function() {
  var searchInput = $('#search input');

  searchInput.autocomplete({
    source: "search",
    minLength: 2,
    focus: function(event, ui) {
      searchInput.val(ui.item.value);
      return false;
    },
    select: function(event, ui) {
      $('#cards').prepend(Deckhand.render(ui.item, 'large'));
      searchInput.val("");
      return false;
    }
  }).data("ui-autocomplete")._renderItem = function(ul, item) {
    var content = Deckhand.render(item, 'small');
    // autocomplete breaks without that intermediate <a> tag
    return $("<li>").append($('<a>').append(content)).appendTo(ul);
  };
});
