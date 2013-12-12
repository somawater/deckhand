//= require jquery
//= require jquery.ui.autocomplete
//= require deckhand/lib/handlebars-v1.1.2

$(function() {
  var smallOrderTemplate = Handlebars.compile($('#small-order-template').html()),
    smallSubscriptionTemplate = Handlebars.compile($('#small-subscription-template').html()),
    smallUserTemplate = Handlebars.compile($('#small-user-template').html());

  var largeOrderTemplate = Handlebars.compile($('#large-order-template').html()),
    largeSubscriptionTemplate = Handlebars.compile($('#large-subscription-template').html()),
    largeUserTemplate = Handlebars.compile($('#large-user-template').html()),

    searchInput = $('#search input');

  searchInput.autocomplete({
    source: "search",
    minLength: 2,
    focus: function(event, ui) {
      searchInput.val(ui.item.value);
      return false;
    },
    select: function(event, ui) {
      switch (ui.item.type) {
        case 'Subscription':
          $('#selected-items').append($('<li>').append(largeSubscriptionTemplate(ui.item)));
        break;
        case 'Order':
          $('#selected-items').append($('<li>').append(largeOrderTemplate(ui.item)));
        break;
        case 'User':
          $('#selected-items').append($('<li>').append(largeUserTemplate(ui.item)));
        break;
      }

      searchInput.val("");

      return false;
    }
  }).data("ui-autocomplete")._renderItem = function(ul, item) {
    var innerContent;
    switch (item.type) {
      case 'Subscription':
        innerContent = smallSubscriptionTemplate(item);
        item.value = 'Subscription '  + item.short_id;
        break;
      case 'Order':
        innerContent = smallOrderTemplate(item);
        item.value = 'Order '  + item.short_id;
        break;
      case 'User':
        innerContent = smallUserTemplate(item);
        item.value = 'User: ' + item.name;
        break;
      default:
        innerContent = '???';
    }
    return $("<li>").append($('<a>').append(innerContent)).appendTo(ul);
  };
});
