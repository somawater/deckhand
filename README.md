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

  model User do
    search_on :short_id, :exact
    search_on :name, :contains
    search_on :email, :contains

    show :subscriptions
    exclude :encrypted_password
  end

  model Subscription do
    show :orders, :charges, :address
  end

  model Charge do
    show :charged_amount_s, :orders
  end

  model ShippingAddress do
    show :to_html_s
  end

end
```

```ruby
# config/routes.rb
mount Deckhand::Engine => 'dh', :as => :deckhand
```

```haml
-# app/views/deckhand/_templates.html.haml

%script(type="text/x-handlebars-template" data-model="user" data-size="small")
  {{name}} &lt;{{email}}&gt;

%script(type="text/x-handlebars-template" data-model="subscription" data-size="small")
  Subscription: {{short_id}}

%script(type="text/x-handlebars-template" data-model="user" data-size="large")
  .panel.panel-primary
    .panel-heading
      %h3.panel-title
        %span.right
          signed up {{humanTime created_at}}
          &nbsp;
          %a.glyphicon.glyphicon-edit.primary(href="/admin/user/{{id}}/edit" target="_blank")
        {{name}} &lt;{{email}}&gt;
    .panel-body

      {{#each subscriptions}}
      {{> subscription_panel}}
      {{/each}}

%script(type="text/x-handlebars-template" data-model="subscription" data-size="panel" data-partial)
  .panel.panel-default
    .panel-heading
      %h3.panel-title
        %span.right
          created {{humanTime created_at}}
          &nbsp;
          %a.glyphicon.glyphicon-edit(href="/admin/subscription/{{id}}/edit" target="_blank")
        Subscription {{short_id}}
    .panel-body
      .row
        .col-sm-6
          %p
            {{#if active}}
            active, recurs {{humanTime next_recurrence_at}}
            {{else}}
            inactive!
            {{#if hidden}}
            also hidden
            {{/if}}
            {{/if}}
          %p {{orders.length}} orders, {{charges.length}} charges
        .col-sm-6
          {{{address.to_html_s}}}
```

Notes for templates:
 * Bootstrap 3 is included.
 * Give your partials the `data-partial` attribute and they'll be registered with the name "#{data-model}_#{data-size}".
