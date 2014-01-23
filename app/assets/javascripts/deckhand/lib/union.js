// array union
// http://stackoverflow.com/questions/3629817/getting-a-union-of-two-arrays-in-javascript
// n.b. this doesn't preserve type, so it only works well with arrays of strings
module.exports = function(x, y) {
  var obj = {};
  for (var i = x.length-1; i >= 0; -- i)
     obj[x[i]] = x[i];
  for (var i = y.length-1; i >= 0; -- i)
     obj[y[i]] = y[i];
  return Object.keys(obj);
};