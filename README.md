# Deckhand

A card-based admin interface.


## Usage

Create `config/initializers/deckhand.rb` like this:

```ruby
Deckhand.configure do

  model Order do
    'todo'
  end

  model User do
    'todo'
  end

  model Subscription do
    'todo'
  end

end
```

Add to `config/routes.rb` like this:

```ruby
mount Deckhand::Engine => 'dh', :as => :deckhand
```
