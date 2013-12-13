var is = {};

is.nil = function (obj) {
  return obj == null;
};

is.bool = function (obj) {
  return typeof obj === 'boolean';
};

is.number = function (obj) {
  return typeof obj === 'number';
};

is.string = function (obj) {
  return typeof obj === 'string';
};

is.object = function (obj) { 
  return Object.prototype.toString.call(obj) === '[object Object]';
};

is.array = function (obj) {
  return obj instanceof Array;
};

is.func = function (obj) {
  return typeof obj === 'function';
};

module.exports = is;
