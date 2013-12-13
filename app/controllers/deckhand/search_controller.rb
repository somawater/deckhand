class Deckhand::SearchController < Deckhand::BaseController

  def show
    render json: results(params[:term]).map {|x| jsonize(x) }
  end

  private

  def jsonize(obj)
    return obj unless Deckhand.config.models.map(&:to_s).include? obj.class.to_s

    obj_hash = {type: obj.class.to_s.underscore}
    Deckhand.config.fields_to_show(obj.class).reduce(obj_hash) do |hash, field|
      val = jsonize obj.send(field)
      if val.is_a? Array
        val = val.map {|subval| jsonize(subval) }
      end
      hash[field] = val
      hash
    end
  end

  def results(term)
    Deckhand.config.model_search.map do |model, search_fields|
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
