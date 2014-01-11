class Deckhand::DataController < Deckhand::BaseController

  def search
    results = Deckhand::Search.new.results(params[:term])
    render_json Deckhand::Presenter.new.present_results(results)
  end

  def show
    instance = Deckhand.config.models_by_name[params[:model]].find(params[:id])
    render_json Deckhand::Presenter.new.present(instance)
  end

  private

  def render_json(data)
    if params[:pretty]
      render json: JSON.pretty_generate(data)
    else
      render json: data
    end
  end

end
