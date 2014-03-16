module.exports = (config) ->
  config.set

    # base path, that will be used to resolve files and exclude
    basePath: '..'

    # frameworks to use
    frameworks: [
      'jasmine'
      'browserify'
    ]

    preprocessors:
      'spec/**/*.coffee': ['browserify']

    browserify:
      extensions: ['.coffee']
      transform: ['coffeeify']
      watch: true
      debug: true


    # list of files / patterns to load in the browser
    files: [
      'spec/support/jquery-1.11.0.js' # load jQuery before angular so that it uses it
      'spec/support/jasmine-jquery.js'
      'spec/support/karma_init.coffee'
      'spec/javascripts/**/*_spec.+(coffee|js)' # load the specs
    ]

    # list of files to exclude
    exclude: []

    # test results reporter to use
    # possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
    reporters: ['progress']

    # web server port
    port: 9876

    # enable / disable colors in the output (reporters and logs)
    colors: true

    # level of logging
    # possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO

    # enable / disable watching file and executing tests whenever any file changes
    autoWatch: true

    # Start these browsers, currently available:
    # - Chrome
    # - ChromeCanary
    # - Firefox
    # - Opera (has to be installed with `npm install karma-opera-launcher`)
    # - Safari (only Mac; has to be installed with `npm install karma-safari-launcher`)
    # - PhantomJS
    # - IE (only Windows; has to be installed with `npm install karma-ie-launcher`)
    browsers: ['PhantomJS']

    # If browser does not capture in given timeout [ms], kill it
    captureTimeout: 60000

    # Continuous Integration mode
    # if true, it capture browsers, run tests and exit
    singleRun: false
