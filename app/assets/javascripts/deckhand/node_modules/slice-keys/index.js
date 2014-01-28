/**
 * Export sliceKeys
 */
module.exports = sliceKeys;

// Helper method for identifying an Array
var isArray = Array.isArray;

// Helper method for slicing an Array.
function sliceArray(array, index){ 
  return Array.prototype.slice.call(array, index); 
}

/**
 * Returns a subset of the `obj` passed that contains only the properties
 * named by `keys`.
 * 
 * For convienence, you may call it either with an array or arguments:
 * 
 *    sliceKeys({x:1, y:2, z:3}, ['x','z']) //=> {x:1, z:3}
 *    sliceKeys({x:1, y:2, z:3}, 'x', 'z')  //=> {x:1, z:3}
 */
function sliceKeys(obj, keys){
  if (!isArray(keys)) {
    keys = sliceArray(arguments, 1);
  }
  
  var key;
  var sliced = {};
  
  for (var i=0, len=keys.length; i < len; i++) {
    key = keys[i];
    
    if (key in obj) {
      sliced[key] = obj[key];
    }
  }
  
  return sliced;
}