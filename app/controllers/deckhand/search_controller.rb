class Deckhand::SearchController < Deckhand::BaseController

  def show
    render json: results(params[:term]).map {|x| jsonize(x) }
  end

  private

  def jsonize(obj)
    obj.as_json.merge(type: obj.class.to_s.downcase)
  end

  def results(term)
    Deckhand.config.searchable_models.map do |model, search_fields|
      criteria = make_criteria(term, search_fields)
      model.or(*criteria).limit(3)
    end.map(&:to_a).flatten(1)
  end

  def make_criteria(term, search_fields)
    search_fields.map do |field, match_type|
      case match_type
      when :exact
        {field => term}
      when :contains
        {field => /#{Regexp.escape term}/i}
      end
    end
  end

end
