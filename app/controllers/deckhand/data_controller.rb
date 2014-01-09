class Deckhand::DataController < Deckhand::BaseController

  def search
    results = Deckhand::Search.new.results(params[:term])
    render json: Deckhand::Presenter.new.present_results(results)
  end

  def show
    instance = Deckhand.config.models_by_name[params[:model]].find(params[:id])
    render json: Deckhand::Presenter.new.present(instance)
  end

end
