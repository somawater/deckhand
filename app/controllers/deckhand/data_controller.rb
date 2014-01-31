class Deckhand::DataController < Deckhand::BaseController

  before_filter :combine_params, only: [:act, :update]

  delegate :present, :present_results, :to => :presenter

  def search
    results = Deckhand.config.model_storage.search(params[:term])
    render_json present_results(results)
  end

  def show
    fields = if params[:fields]
      requested = params[:fields].split(',').compact.map(&:to_sym)
      model_config.fields_to_show.select do |field, options|
        requested.include?(field)
      end
    end

    render_json present(instance, fields)
  end

  def form
    case params[:type]
    when 'action'
      form = model_config.action_form_class(params[:act]).new object: instance
      render_json(
        title: form.title,
        prompt: form.prompt,
        values: form.values
      )
    when 'edit'
      edit_fields = params[:edit_fields] || model_config.fields_to_edit
      initial_values = present(instance, edit_fields)
      # FIXME this and the implementation of form.values need to be merged
      render_json values: Hash[*(initial_values.map {|k,v| [k, {value: v}]}.flatten)]
    else
      raise "unknown type: #{params[:type]}"
    end
  end

  def act
    action = params[:act].to_sym

    if model_config.has_action_form?(action)
      form = model_config.action_form_class(action).new params[:form].merge(object: instance)
      if form.valid?
        begin
          result = form.execute
          if result
            render_json(
              result: present(result),
              success: form.success,
              warning: form.warning,
              info: form.info,
              changed: form.changed_objects.map {|obj| present(obj) }
            )
          else
            render_error form.error
          end
        rescue
          render_error $!.message
        end
      else
        render_error form.errors.full_messages.join('; ')
      end

    elsif model_config.has_action?(action)
      # TODO: begin/rescue/end the public_send and return a status code
      result = instance.public_send(params[:act].to_sym)
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
    # FIXME mongoid-specific
    if instance.update_attributes params[:form].except(:id), without_protection: true
      render_json changed: [present(instance)]
    else
      render_error instance.errors.full_messages.join('; ')
    end
  end

  private

  def presenter
    Deckhand::Presenter.new params.slice(:eager_load)
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

  def instance
    @instance ||= Deckhand.config.model_class(params[:model]).find(params[:id])
  end

  def model_config
    @model_config ||= Deckhand.config.for_model(params[:model])
  end

  # this is a workaround for the way angular-file-upload works.
  # it splits up top-level parameters into their own parts of the response
  # and stringifies them in a way that Rails can't deal with automatically,
  # so we put them into a subtree keyed with "non_file_params" and parse
  # them here.
  def combine_params
    return unless params[:non_file_params]

    non_file_params = JSON.load(params[:non_file_params])

    # copy this first so we can load the instance
    params[:model] = non_file_params['model']

    non_file_params['form'].tap do |form|
      # remove the previous values for the file attachment fields
      form.keys.each do |key|
        if Deckhand.config.attachment? instance.class, key.to_sym
          form.delete(key)
        end
      end
      # add the uploaded files
      form.merge!(params[:form]) if params[:form]
    end

    params.merge! non_file_params
    params.delete :non_file_params
  end

end
