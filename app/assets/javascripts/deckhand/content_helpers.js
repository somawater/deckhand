
Dombars.registerHelper('humanTime', function(time) {
  return time ? moment(new Date(time)).fromNow() : 'never';
});

Dombars.registerHelper('pluralize', function(value, text) {
  return value == 1 ? text : text + 's';
});
