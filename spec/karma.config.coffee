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
      'app/assets/javascripts/deckhand/index.coffee': ['browserify']
      'spec/**/*.coffee': ['coffee']

    browserify:
      extensions: ['.coffee']
      transform: ['coffeeify']
      watch: true
      debug: true


    # list of files / patterns to load in the browser
    files: [
      'spec/support/karma_init.coffee'
      'app/assets/javascripts/deckhand/index.coffee' # load the application, have browserify serve it
      {
        # watch application files, but do not serve them from Karma since they are served by browserify
        pattern: 'app/assets/javascripts/deckhand/*.+(coffee|js)'
        watched: true
        included: false
        served: false
      }
      'spec/support/**/*.+(coffee|js)' # load specs dependencies
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