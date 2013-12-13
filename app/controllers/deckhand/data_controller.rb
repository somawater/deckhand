class Deckhand::DataController < Deckhand::BaseController

  def search
    render json: results(params[:term]).map {|x| jsonize(x) }
  end

  def show
    instance = find(params[:model], params[:id])
    render json: jsonize(instance)
  end

  private

  def find(model, id)
    Deckhand.config.models_by_name[model].find(id)
  end

  def jsonize(obj)
    model = obj.class
    return obj unless Deckhand.config.has_model? model

    obj_hash = {type: model.to_s.underscore}
    Deckhand.config.fields_to_show(model).reduce(obj_hash) do |hash, field|
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
