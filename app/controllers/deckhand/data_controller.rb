class Deckhand::DataController < Deckhand::BaseController
  include NormalizeParams

  before_filter :normalize_params, only: [:act, :update]

  delegate :present, :present_results, :to => :presenter

  def search
    results = Deckhand.config.model_storage.search(data_params[:term], data_params[:model])
    render_json present_results(results)
  end

  def show
    if data_params[:id] == 'list'
      plural = data_params[:model].pluralize
      list = {_model: data_params[:model], _label: plural, id: 'list'}

      list_config = model_config.list
      scope = list_config[:scope] || 'all'

      # TODO pagination
      list[plural.downcase] = model_class.send(scope).to_a.map do |item|
        present(item, list_config[:table])
      end

      render_json list

    else
      fields = if data_params[:fields]
        requested = data_params[:fields].split(',').compact.map(&:to_sym)
        model_config.fields_to_show.select do |field, options|
          requested.include?(field)
        end
      end

      render_json present(instance, fields)
    end
  end

  def form
    case data_params[:type]
    when 'action'
      form = form_class.new object: instance
      render_json(
        title: form.title,
        prompt: form.prompt,
        values: form.values
      )
    when 'edit'
      edit_fields = data_params[:edit_fields] || model_config.fields_to_edit
      initial_values = present(instance, edit_fields)
      # FIXME this and the implementation of form.values need to be merged
      render_json values: Hash[*(initial_values.map {|k,v| [k, {value: v}]}.flatten)]
    else
      raise "unknown type: #{data_params[:type]}"
    end
  end

  def act
    action = data_params[:act].to_sym

    if model_config.try(:has_action_form?, action) || Deckhand.config.has_action?(action)
      process_form

    elsif model_config.has_action?(action)
      # TODO: begin/rescue/end the public_send and return a status code
      result = instance.public_send(data_params[:act].to_sym)
      if result
        render_json(
          result: present(result),
          changed: [present(instance)]
        )
      else
        render_error form.error
      end
    else
      render_error 'unknown action'
    end
  end

  def update
    puts data_params.inspect
    if Deckhand.config.model_storage.update instance, data_params[:form].except(:id, :_model, :_label)
      render_json changed: [present(instance)]
    else
      render_error instance.errors.full_messages.join('; ')
    end
  end

  private

  def process_form
    form = form_class.new data_params[:form].merge(object: instance)
    if form.valid?
      begin
        result = form.execute
        if result
          render_json(
            result: present(result),
            success: form.success,
            warning: form.warning,
            info: form.info,
            changed: form.changed_objects.map { |obj| present(obj) }
          )
        else
          render_error form.errors.full_messages.join('<br/>')
        end
      rescue
        render_error $!.message
      end
    else
      render_error form.errors.full_messages.join('<br/>')
    end
  end

  def presenter
    Deckhand::Presenter.new params.slice(:eager_load)
  end

  def render_json(data, status = :ok)
    if data_params[:pretty]
      render json: JSON.pretty_generate(data), status: status
    else
      render json: data, status: status
    end
  end

  # TODO more flexible error presentation
  def render_error(message)
    render json: {error: message}, status: :unprocessable_entity
  end

  def model_class
    @model_class ||= Deckhand.config.model_class(data_params[:model]) if data_params[:model]
  end

  def instance
    @instance ||= model_class.try(:find, data_params[:id]) if data_params[:id]
  end

  def data_params
    # This basically permits any parameters to be passed. Previously, we ran any model updates
    # without_protection, so it does the same thing. That being said, you should not do this.
    # It's very insecure.
    params.permit!
  end
end
