var assert = require("assert");
var slice  = require("../index");

describe('slice-keys', function(){

  describe('slicing object', function(){
    it('only returns requested keys', function(){
      var object = {x: 1, y: 2, z: 3};
      var sliced = slice(object, ['x','z']);
      
      assert.deepEqual({x: 1, z: 3}, sliced);
    });
    
    it('only returns existing keys', function(){
      var object = {x: 1, y: 2, z: 3};
      var sliced = slice(object, ['x','Q']);
      
      assert.deepEqual({x: 1}, sliced);
    });
    
    it('returns falsey keys', function(){
      var object = {x: false, y: null, z: undefined};
      var sliced = slice(object, ['x','y','z']);
      
      assert('x' in sliced);
      assert('y' in sliced);
      assert('z' in sliced);
    });
    
    it('returns an empty object if there are no matching keys', function(){
      var object = {x: 1, y: 2, z: 3};
      var sliced = slice(object, ['X','Y','Z']);
      
      assert.deepEqual({}, sliced);
    });
  });
  
  describe('calling', function(){
    it('can be done with an array', function(){
      var object = {x: 1, y: 2, z: 3};
      var sliced = slice(object, ['x','z']);
      
      assert.equal(2, Object.keys(sliced).length);
    });
    
    it('can be done with arguments', function(){
      var object = {x: 1, y: 2, z: 3};
      var sliced = slice(object, 'x','z');
      
      assert.equal(2, Object.keys(sliced).length);
    });
  });
  
});