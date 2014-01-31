class Deckhand::ModelStorage::Base

  def search(term, model = nil)
    search_configs = if model
      [[model, Deckhand.config.for_model(model)]]
    else
      Deckhand.config.models_config
    end

    search_configs.map do |model, config|
      next unless config.searchable?

      options = config.search_options
      scope = model.constantize
      scope = scope.send(options[:scope]) if options[:scope]

      query(scope, term, options[:fields])
    end.map(&:to_a).flatten(1)
  end

  protected

  def query(scope, term, fields)
    raise NotImplementedException
  end

end