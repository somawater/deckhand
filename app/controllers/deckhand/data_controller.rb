class Deckhand::DataController < Deckhand::BaseController

  delegate :present, :present_results, :to => :presenter

  def search
    results = Deckhand::Search.new.results(params[:term])
    render_json present_results(results)
  end

  def show
    instance = get_instance
    render_json present(instance)
  end

  def act
    instance = get_instance
    action = params[:act].to_sym

    if Deckhand.config.for_model(instance.class).has_action?(action)
      # TODO: begin/rescue/end the public_send and return a status code
      result = instance.public_send(params[:act].to_sym)
      render_json present(instance).merge(_result: present(result))
    else
      render_json({error: 'unknown action'}, :unprocessable_entity)
    end
  end

  private

  def presenter
    Deckhand::Presenter.new
  end

  def render_json(data, status = :ok)
    if params[:pretty]
      render json: JSON.pretty_generate(data), status: status
    else
      render json: data, status: status
    end
  end

  def get_instance
    Deckhand.config.models_by_name[params[:model]].find(params[:id])
  end

end
