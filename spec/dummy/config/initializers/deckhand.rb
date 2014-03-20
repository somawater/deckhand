if Rails.env.development?
  config_file = Rails.root.join('config/initializers/deckhand.rb')
  Deckhand::Engine.config.watchable_files << config_file
end

Deckhand.configure do
end
