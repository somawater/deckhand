require 'deckhand/configuration/model_dsl'

class Deckhand::Configuration::ModelConfig
  attr_reader :model, :fields_to_show, :fields_to_include

  def initialize(options = {}, &block)

    default_options = {
      singular: [:label, :fields_to_show, :search_scope],
      defaults: {show: [], exclude: []}
    }
    @label_defaults = options.delete(:label_defaults)
    @model = options.delete(:model)
    @dsl = Deckhand::Configuration::ModelDSL.new(default_options.merge(options), &block)

    @fields_to_show = @dsl.show.each do |name, options|
      complete_options(name, options)
    end

    @fields_to_include = fields_to_show.dup.tap do |fields|
      names = fields.map(&:first)
      actions.map {|a| a.last[:if] }.compact.each do |action|
        unless names.include?(action)
          fields << [action, complete_options(action, {})]
        end
      end
    end

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

  def flat_fields
    fields_to_show.reject {|name, options| options[:table] }
  end

  def table_fields
    fields_to_show.select {|name, options| options[:table] }
  end

  def fields_to_edit
    @fields_to_edit ||= begin
      show_and_edit = fields_to_show.select do |name, options|
        options[:editable] && (!options[:editable].is_a?(Hash) || !options[:editable][:nested])
      end
      edit_only = @dsl.edit || []
      (show_and_edit + edit_only).map do |name, options|
        options[:type] = :file if Deckhand.config.attachment?(@model, name)
        [name, options]
      end
    end
  end

  def actions
    @dsl.action || []
  end

  def searchable?
    !!search_options[:fields]
  end

  def search_options
    {scope: @dsl.search_scope, fields: @dsl.search_on}
  end

  def field_options(name)
    fields_to_include.detect {|n, _| n == name }.try :last
  end

  def add_field_to_include(name)
    unless fields_to_include.map(&:first).include? name
      fields_to_include << [name, complete_options(name, {})]
    end
  end

  def as_json(*args)
    Hash[fields_to_include].as_json(*args)
  end

  private

  def complete_options(name, options)
    unless options.include? :class_name
      options[:class_name] = Deckhand.config.model_storage.relation_class_name @model.to_s, name
    end

    unless options.include? :type
      options[:type] = if options[:class_name]
        :relation
      else
        Deckhand.config.model_storage.field_type @model, name
      end
    end

    unless options.include? :name
      options[:name] = name
    end

    options
  end

end