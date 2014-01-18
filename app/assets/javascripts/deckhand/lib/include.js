module.exports = function(file, callback) {
  var head      = document.getElementsByTagName('head')[0];
  var script    = document.createElement('script');
  script.type   = 'text/javascript';
  script.src    = file;
  script.onload = script.onreadystatechange = function() {
    // execute dependent code
    if (callback) callback();
    // prevent memory leak in IE
    head.removeChild(script);
    script.onload = null;
  };
  head.appendChild(script);
};
