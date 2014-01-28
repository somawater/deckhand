require 'active_support/core_ext/class/attribute'
require 'active_model'
require 'backport/active_model/model'

class Deckhand::Form
  extend ActiveModel::Callbacks
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  class_attribute :inputs

  attr_accessor :object

  def self.inherited(subclass)
    subclass.inputs = {}
  end

  class << self
    def input(name, options = {})
      attr_accessor name
      self.inputs[name] = options
    end

    def object_name(name)
      alias_method name, :object
    end
  end

  def initialize(params = {})
    self.object = params[:object]

    # because we're iterating through all inputs, not just the ones passed
    # to the constructor, this will set any missing inputs to nil or false
    self.class.inputs.each do |name, options|
      send "#{name}=", resolve_value(params[name], options)
    end

    super()
  end

  def values
    @values ||= inputs.reduce({}) do |h, (name, options)|
      h[name] = {
        value: send(name),
        choices: (send(options[:choices]) if options[:choices])
      }
      h
    end
  end

  def execute
    raise NotImplementedError
  end

  def changed_objects
    raise NotImplementedError
  end

  private

  def resolve_value(value, options)
    type = options[:type]
    if !value and default = options[:default]
      (default == true || default == false) ? default : send(default)
    elsif type == :boolean
      !!value
    elsif !value
      nil
    elsif type == Integer
      value.to_i
    elsif type == Float
      value.to_f
    else
      value
    end
  end

end