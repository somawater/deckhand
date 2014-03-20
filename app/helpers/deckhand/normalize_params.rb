module Deckhand::NormalizeParams
  # this is a workaround for the way angular-file-upload works.
  # it splits up top-level parameters into their own parts of the response
  # and stringifies them in a way that Rails can't deal with automatically,
  # so we put them into a subtree keyed with "non_file_params" and parse
  # them here.
  def normalize_params
    return unless params[:non_file_params]

    non_file_params = parse_from_json(params[:non_file_params])
    prepare_instance(non_file_params)
    fix_file_attachment_params(non_file_params)

    params.merge! non_file_params
    params.delete :non_file_params
    logger.debug "Normalized parameters: #{params.inspect}" if defined? Rails
  end

  private

  def parse_from_json(json_params)
    JSON.load(json_params)
  end

  def prepare_instance(non_file_params)
    params[:model] ||= non_file_params['model']
    params[:act] ||= non_file_params['act']
  end

  def fix_file_attachment_params(non_file_params)
    non_file_params['form'].tap do |form|
      remove_original_file_attachment_values(form)
      merge_files_in_groups(form)
      merge_actual_file_attachment_values(form)
    end
  end

  def remove_original_file_attachment_values(form)
    form.keys.each do |key|
      form.delete(key) if Deckhand.config.attachment? instance.class, key.to_sym
    end
  end

  def merge_files_in_groups(form)
    return unless params[:form]

    params[:form].keys.each do |key|
      group, field = key.split(".")
      next unless field
      form[group].delete(field)
      form[group][field] = params[:form][key]
    end
  end

  def merge_actual_file_attachment_values(form)
    form.merge!(params[:form]) if params[:form]
  end
end
