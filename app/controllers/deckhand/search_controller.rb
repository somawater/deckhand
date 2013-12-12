class Deckhand::SearchController < Deckhand::BaseController

  def show
    render json: dummy_data.map {|x| jsonize(x) }
  end

  private

  def jsonize(obj)
    obj.as_json.merge(type: obj.class.to_s.downcase)
  end

  def dummy_data
    Deckhand.config.models.keys.map do |model|
      model.order_by(:created_at.desc).limit(3).to_a
    end.flatten(1).shuffle
  end

end
