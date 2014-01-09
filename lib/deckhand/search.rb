class Deckhand::Search

  def results(term)
    Deckhand.config.search_config.map do |model, search_fields|
      criteria = make_criteria(term, search_fields)
      model.or(*criteria).limit(5)
    end.map(&:to_a).flatten(1)
  end

  def make_criteria(term, search_fields)
    search_fields.map do |field, match_type|
      case match_type
      when :exact, nil
        {field => term}
      when :contains
        {field => /#{Regexp.escape term}/i}
      end
    end
  end

end