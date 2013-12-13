/*jshint browser: true, node: true */

"use strict";

var or = require('or');

module.exports = delegation;

// Shim for matchesSelector
var matchesSelector = or(['matchesSelector', 'mozMatchesSelector',
    'webkitMatchesSelector', 'oMatchesSelector',
    'msMatchesSelector'], function(shim) {
    return shim in document.documentElement;
});

function delegation(parent, evt, selector, fn) {
    parent.addEventListener(evt, function(e) {
        var elt = function find(el) {
            if (el[matchesSelector](selector)) {
                return el;
            }

            if (el.parentNode !== parent) {
                return find(el.parentNode);
            }

            return false;
        }(e.target);

        if (elt) {
            fn.apply(elt, arguments);
        }
    }, false);
}

