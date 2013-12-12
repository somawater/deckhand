# Deckhand

A card-based admin interface.


## Usage

Make the following changes in your main app:

```ruby
# Gemfile
gem 'deckhand', github: 'somawater/deckhand'
```

```ruby
# config/initializers/deckhand.rb
Deckhand.configure do
  model Order do
    search_on :short_id, :exact
  end
  model User do
    search_on :name, :contains
    search_on :email, :contains
  end
  model Subscription do
    search_on :short_id, :contains
  end
end
```

```ruby
# config/routes.rb
mount Deckhand::Engine => 'dh', :as => :deckhand
```

```haml
-# app/views/deckhand/_templates.html.haml

%script#template-order-small(type="text/x-handlebars-template")
  Order: {{short_id}}

%script#template-user-small(type="text/x-handlebars-template")
  User: {{name}}

%script#template-subscription-small(type="text/x-handlebars-template")
  Subscription: {{short_id}}

%script#template-order-large(type="text/x-handlebars-template")
  .well
    %h1 Order: {{short_id}}
    Created At: {{created_at}}
    State: {{state}}

%script#template-user-large(type="text/x-handlebars-template")
  .well
    %h1 User: {{name}}
    Email: {{email}}

%script#template-subscription-large(type="text/x-handlebars-template")
  .well
    %h1 Subscription: {{short_id}}
    Created_at: {{created_at}}
```

Notes for templates:
 * Bootstrap 3 is available.
 * Give the templates ID's in the format `"template-#{class.to_s.parameterize.dasherize}-#{size}"`
