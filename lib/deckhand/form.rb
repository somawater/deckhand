require 'active_support/core_ext/class/attribute'
require 'active_model'
require 'backport/active_model/model'

class Deckhand::Form
  extend ActiveModel::Callbacks
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  class_attribute :inputs

  attr_accessor :object
  attr_accessor :success, :info, :warning, :error
  alias_method :notice, :info
  alias_method :notice=, :info=

  def self.inherited(subclass)
    subclass.inputs = {}
  end

  class << self
    def input(name, options = {})
      if @current_multiple_input
        @current_multiple_input[:inputs][name] = options
      else
        attr_accessor name
        self.inputs[name] = options
      end
    end

    def multiple(name, options = {}, &block)
      attr_accessor name
      @current_multiple_input = {inputs: {}, multiple: true, default: []}.merge(options)
      self.inputs[name] = @current_multiple_input
      block.call
      @current_multiple_input = nil
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
    []
  end

  def title
  end

  def prompt
  end

  private

  def resolve_value(value, options)
    type = options[:type]

    if !value and default = options[:default]
      [true, false, []].include?(default) ? default : send(default)

    elsif type == :boolean
      !!value

    elsif !value
      nil

    elsif type == Integer
      value.to_i

    elsif type == Float
      value.to_f

    elsif options[:multiple]
      value.map do |subval|
        resolved = subval.map do |k, v|
          sym = k.to_sym
          [sym, resolve_value(v, options[:inputs][sym])]
        end.flatten
        ActiveSupport::HashWithIndifferentAccess.new Hash[*resolved]
      end

    else
      value
    end
  end

end