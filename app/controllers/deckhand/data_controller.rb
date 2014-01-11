class Deckhand::DataController < Deckhand::BaseController

  def search
    results = Deckhand::Search.new.results(params[:term])
    render_json Deckhand::Presenter.new.present_results(results)
  end

  def show
    instance = get_instance
    render_json Deckhand::Presenter.new.present(instance)
  end

  def update
    instance = get_instance
    # TODO: begin/rescue/end the public_send and return a status code
    result = instance.public_send(params[:act].to_sym)
    render_json Deckhand::Presenter.new.present(instance).merge(_result: result)
  end

  private

  def render_json(data)
    if params[:pretty]
      render json: JSON.pretty_generate(data)
    else
      render json: data
    end
  end

  def get_instance
    Deckhand.config.models_by_name[params[:model]].find(params[:id])
  end

end
