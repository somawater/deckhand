delegation
===

Purpose
---

Implements event delegation.

Example
---

```javascript
var delegate = require('delegation');

delegate(document, 'click', 'li', function(e) {
    console.log(this.nodeName); // "LI"
});
```

API
---

The module returns a function with four arguments:

- `parent`: the parent on which to listen for the event
- `event`: the event to listen to
- `selector`: the selector for the elements to delegate to
- `handler`: the event handler

Installation
---

    npm install delegation

Contributors
---

- [Florian Margaine](http://margaine.com)

License
---

MIT License.
