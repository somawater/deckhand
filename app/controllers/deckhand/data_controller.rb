class Deckhand::DataController < Deckhand::BaseController

  before_filter :normalize_params, only: [:root_act, :act, :update]

  delegate :present, :present_results, :to => :presenter

  def search
    results = Deckhand.config.model_storage.search(params[:term], params[:model])
    render_json present_results(results)
  end

  def show
    if params[:id] == 'list'
      plural = params[:model].pluralize
      list = {_model: params[:model], _label: plural, id: 'list'}

      list_config = model_config.list
      scope = list_config[:scope] || 'all'

      # TODO pagination
      list[plural.downcase] = model_class.send(scope).to_a.map do |item|
        present(item, list_config[:table])
      end

      render_json list

    else
      fields = if params[:fields]
        requested = params[:fields].split(',').compact.map(&:to_sym)
        model_config.fields_to_show.select do |field, options|
          requested.include?(field)
        end
      end

      render_json present(instance, fields)
    end
  end

  def form
    case params[:type]
    when 'root_action', 'action'
      form = form_class.new object: instance
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

  def root_act
    process_form
  end

  def act
    action = params[:act].to_sym

    if model_config && model_config.has_action_form?(action)
      process_form

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
    if Deckhand.config.model_storage.update instance, params[:form].except(:id)
      render_json changed: [present(instance)]
    else
      render_error instance.errors.full_messages.join('; ')
    end
  end

  private

  def process_form
    form = form_class.new params[:form].merge(object: instance)
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
          render_error form.error
        end
      rescue
        render_error $!.message
      end
    else
      render_error form.errors.full_messages.join('; ')
    end
  end

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

  def model_class
    @model_class ||= Deckhand.config.model_class(params[:model])
  end

  def instance
    @instance ||= params[:id].blank? ? form_class.new : model_class.find(params[:id])
  end

  # this is a workaround for the way angular-file-upload works.
  # it splits up top-level parameters into their own parts of the response
  # and stringifies them in a way that Rails can't deal with automatically,
  # so we put them into a subtree keyed with "non_file_params" and parse
  # them here.
  def normalize_params
    return unless params[:non_file_params]

    non_file_params = JSON.load(params[:non_file_params])

    # copy this first so we can load the instance
    params[:model] ||= non_file_params['model']
    params[:act] ||= non_file_params['act']

    fix_file_attachment_params(non_file_params)

    params.merge! non_file_params
    params.delete :non_file_params

    Rails.logger.debug "  Normalized parameters: #{params.inspect}"
  end

  def fix_file_attachment_params(non_file_params)
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
  end

end
