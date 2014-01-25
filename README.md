# Deckhand

A card-based admin interface.

It's a Rails engine with a DSL that produces an Angular.js app for viewing and manipulating your domain objects.

## Requirements

Tested with the latest Ruby (2.0)

Node.js, NPM and [Browserify](http://browserify.org) are required.

## Usage

Make the following changes in your main app:

```ruby
# Gemfile
gem 'deckhand', github: 'somawater/deckhand'
```

```ruby
# config/initializers/deckhand.rb
Deckhand.configure do
  # examples forthcoming...
end
```

## Tips and troubleshooting

### Auto-reloading in development

Add the following to `config/initializers/deckhand.rb` or anywhere else in the Rails startup sequence:
```ruby
if Rails.env.development?
  config_file = Rails.root.join('config/initializers/deckhand.rb')
  Deckhand::Engine.config.watchable_files << config_file
end
```

### Spork

Add this to the prefork block in `spec_helper.rb` ([why?](https://github.com/sporkrb/spork/wiki/Spork.trap_method-Jujitsu)):

```ruby
require 'deckhand'
Spork.trap_method(Deckhand::Configuration, :run)
```

### Heroku

You may want to use [this Ruby buildpack](https://github.com/somawater/heroku-buildpack-ruby), which uses the newest version of Node.js according to [semver.io](http://semver.io). [ddollar's multi-buildpack](https://github.com/ddollar/heroku-buildpack-multi) is another option, which we haven't tested.

----

[Lawrence](http://github.com/levity) and [Matthias](http://github.com/natarius) at [Soma](https://www.drinksoma.com)
