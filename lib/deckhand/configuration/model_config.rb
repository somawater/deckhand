require 'deckhand/configuration/model_dsl'

class Deckhand::Configuration::ModelConfig
  attr_reader :model

  def initialize(options = {}, &block)
    @label_defaults = options.delete(:label_defaults)
    @model = options.delete(:model)
    @dsl = Deckhand::Configuration::ModelDSL.new(options, &block)
  end

  # a model's label can either be a symbol name of a method on that model,
  # or a block that will be eval'ed in instance context.
  # it can be defined in the model's configuration block with the "label" keyword,
  # or fall back to the "model_label" keyword at the top level of configuration.
  # the top-level configuration only supports methods, not blocks.
  def label
    @dsl.label ||= @label_defaults.detect {|attr| @model.method_defined? attr } || @label_defaults.last
  end

  def has_action?(action)
    actions.map(&:first).include? action
  end

  def has_action_form?(action)
    has_action?(action) and actions.any? {|name, options| name == action && options.include?(:form) }
  end

  def action_form_class(action)
    model.const_get(action.to_s.camelize)
  end

  def fields_to_show(options = {})
    options[:flat_only] ? @dsl.show.reject {|name, options| options[:table] } : @dsl.show
  end

  def actions
    @dsl.action || []
  end

  def fields_to_include(options = {})
    action_conditions = actions.map {|a| a.last[:if] }.compact.map {|f| [f, {}] }
    fields_to_show(options) + action_conditions # TODO de-duplicate
  end

  def search_fields
    @dsl.search_on
  end

end