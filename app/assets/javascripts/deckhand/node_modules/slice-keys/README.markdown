slice-keys
==========

Returns a subset of the given object with only the requested attributes.

    sliceKeys({x:1, y:2, z:3}, ['x','z']) //=> {x:1, z:3}
    sliceKeys({x:1, y:2, z:3}, 'x', 'z')  //=> {x:1, z:3}
    
This is particularly useful when filtering user input:

    params = {name: "Monty Pontihew", admin: true};
    allow  = ['name', 'age'];
    
    user.update(sliceKeys(params, allow)); // Only name will be passed in

Installation
------------
Install with `npm`:

    npm install slice-keys

Tests
-----
Test with `mocha`:

    mocha
    
Enjoy.

----

[Adam Sanderson](http://monkeyandcrow.com)