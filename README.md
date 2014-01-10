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

= deckhand_template :user, :search_result do
  {{name}} &lt;{{email}}&gt;

= deckhand_template :subscription, :search_result do
  Subscription: {{short_id}}

= deckhand_template :user, :card do
  .panel.panel-primary
    .panel-heading
      %h3.panel-title
        %span.right
          signed up {{humanTime created_at}}
          &nbsp;
          %a.glyphicon.glyphicon-edit.primary(href="/admin/user/{{id}}/edit" target="_blank")
        {{name}} &lt;{{email}}&gt;
    .panel-body
      {{subscriptions.length}} {{pluralize subscriptions.length 'subscription'}}:
      %ul.comma-separated
        {{#each subscriptions}}
        %li
          %a(data-model="subscription" data-id="{{id}}") {{short_id}}
        {{/each}}

= deckhand_template :subscription, :card do
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
          %p {{plan.name}}
          %p
            {{#if active}}
            %strong.good active,
            recurs {{humanTime next_recurrence_at}}
            {{else}}
            %strong.bad
              inactive
              {{#if hidden}}
              and hidden
              {{/if}}
            {{/if}}
          %p
            {{charges.length}} {{pluralize charges.length 'charge'}},
            {{orders.length}} {{pluralize orders.length 'order'}}
        .col-sm-6
          {{{address.to_html_s}}}

```

Notes for templates:
 * Bootstrap 3 is included.
 * `pluralize` and `humanTime` helpers are included.
 * Links with `data-model` and `data-id` will open a new card.


## Troubleshooting

### Spork

Add this to the prefork block in `spec_helper.rb` ([why?](https://github.com/sporkrb/spork/wiki/Spork.trap_method-Jujitsu)):

```ruby
require 'deckhand'
Spork.trap_method(Deckhand::Configuration, :run)
```
