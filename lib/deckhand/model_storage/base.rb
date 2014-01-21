class Deckhand::ModelStorage::Base

  def search(term)
    Deckhand.config.models_config.map do |model, config|
      next unless config.searchable?

      options = config.search_options
      scope = model
      scope = scope.send(options[:scope]) if options[:scope]

      query(scope, term, options[:fields])
    end.map(&:to_a).flatten(1)
  end

  protected

  def query(scope, term, fields)
    raise NotImplementedException
  end

end