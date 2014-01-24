require 'active_support/core_ext/class/attribute'
require 'active_model'

module Deckhand::Form

  def self.included(base)
    base.instance_eval do
      extend ActiveModel::Callbacks
      include ActiveModel::Model
      include ActiveModel::Validations::Callbacks

      class_attribute :inputs
      self.inputs = {}

      attr_accessor :object
      extend ClassMethods
    end
  end

  def initialize(*args)
    super
    inputs.each do |name, options|
      if default = options[:default]
        val = default.is_a?(Boolean) ? default : send(default)
        send "#{name}=", val
      end
    end
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

  def consume_params(params)
    # note that this allows setting boolean values to false
    # without the need for a hidden input on the client side
    inputs.each do |name, options|
      value = if p = params[name]
        type = options[:type]
        if type == Integer
          p.to_i
        elsif type == Float
          p.to_f
        else
          p
        end
      end
      send "#{name}=", value
    end
  end

  def execute
    raise NotImplementedError
  end

  def changed_objects
    raise NotImplementedError
  end

  module ClassMethods
    def input(name, options = {})
      attr_accessor name
      self.inputs[name] = options
    end

    def object_name(name)
      alias_method name, :object
    end
  end

end