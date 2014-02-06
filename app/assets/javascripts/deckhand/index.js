window.extend = require('extend');
window.slice = require('slice-keys');

var moment = require('moment'),
  scroll = require('scroll');

require('angular');
require('./lib/angular-resource');
require('./lib/angular-sanitize');
require('./lib/angular-animate');
require('./lib/angular-ui-bootstrap-0.10.0');
require('./lib/angular-ui-bootstrap-tpls-0.10.0');
require('./lib/angular-file-upload');

Deckhand.app = angular.module('Deckhand',
  ['ngResource', 'ngSanitize', 'ngAnimate', 'angularFileUpload', 'ui.bootstrap']);

require('./controllers');
require('./services');
require('./directives.coffee');

Deckhand.app.filter('humanTime', function() {
  return function(time) {
    return time ? moment(new Date(time)).fromNow() : 'never';
  }
})

.filter('pluralize', function() {
  return function(quantity) {
    return quantity == 1 ? '' : 's';
  }
})

.filter('readableMethodName', function() {
  return function(name) {
    return name.replace(/_/g, ' ');
  }
})

.run(['$rootScope', function($rootScope) {

  document.getElementById('cards').addEventListener('focusItem', function(event) {
    var index = event.detail.index + 1; // nth-child is 1-indexed
    var scrollOptions = {duration: 800, ease: 'outQuint'};
    if (index == 1) {
      scroll.top(document.documentElement, 0, scrollOptions);
    } else {
      var selector = '#cards > div:nth-child(' + index + ')';
      var element = document.querySelector(selector);
      scroll.top(document.documentElement, element.offsetTop, scrollOptions);
    }
  });

}]);
