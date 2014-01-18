class Deckhand::Search

  attr_reader :results

  def initialize(term)
    model_storage = Deckhand.config.global_config.model_storage
    @results = model_storage.search(term)
  end

end