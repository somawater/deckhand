class Deckhand::Configuration::ActionConfig
  attr_reader :action, :label

  def initialize(options = {})
    %w[action label class_name].each do |attr|
      instance_variable_set :"@#{attr}", options[attr.to_sym]
    end
  end

  def form_class
    @form_class ||= @class_name ? @class_name.constantize : action.to_s.camelize.constantize
  end

end