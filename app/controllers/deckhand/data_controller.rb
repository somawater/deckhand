class Deckhand::DataController < Deckhand::BaseController

  delegate :present, :present_results, :to => :presenter

  def search
    results = Deckhand::Search.new(params[:term]).results
    render_json present_results(results)
  end

  def show
    instance = get_instance
    render_json present(instance)
  end

  def form
    instance = get_instance
    model_config = Deckhand.config.for_model(instance.class)
    if params[:act]
      form = model_config.action_form_class(params[:act]).new object: instance
      render_json form.values
    elsif edit_fields = params[:edit_fields]
      render_json present(instance, [], edit_fields)
    end
  end

  def act
    instance = get_instance
    action = params[:act].to_sym
    model_config = Deckhand.config.for_model(instance.class)

    if model_config.has_action_form?(action)
      form = model_config.action_form_class(action).new object: instance
      form.consume_params(params[:form])
      if form.valid?
        result = form.execute
        render_json present(instance).merge(_result: present(result))
      else
        render_error form.errors.full_messages.join('; ')
      end

    elsif model_config.has_action?(action)
      # TODO: begin/rescue/end the public_send and return a status code
      result = instance.public_send(params[:act].to_sym)
      render_json present(instance).merge(_result: present(result))

    else
      render_error 'unknown action'
    end
  end

  def update
    instance = get_instance
    if instance.update_attributes(params[:form])
      render_json present(instance)
    else
      render_error instance.errors.full_messages.join('; ')
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

  # TODO more flexible error presentation
  def render_error(message)
    render json: {error: message}, status: :unprocessable_entity
  end

  def get_instance
    Deckhand.config.models_by_name[params[:model]].find(params[:id])
  end

end
