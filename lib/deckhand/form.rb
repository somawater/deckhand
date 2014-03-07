require 'active_support/core_ext/class/attribute'
require 'active_model'
require 'backport/active_model/model'
require 'deckhand/open_struct_without_table'

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
    def group(name, options = {}, &block)
      @current_group_input = {inputs: {}, group: true, default: {}}.merge(options)
      attr_accessor name
      self.inputs[name] = @current_group_input
      block.call
      @current_group_input[:inputs].each {|name, options| @current_group_input[:default][name] = options[:default] if options[:default]}
      @current_group_input = nil
    end

    def input(name, options = {})
      if @current_multiple_input
        @current_multiple_input[:inputs][name] = options
      elsif @current_group_input
        @current_group_input[:inputs][name] = options
      else
        attr_accessor name
        self.inputs[name] = options
      end
    end

    def multiple(name, options = {}, &block)
      @current_multiple_input = {inputs: {}, multiple: true, default: []}.merge(options)
      block.call
      if @current_group_input
        @current_group_input[:inputs][name] = @current_multiple_input
      else
        attr_accessor name
        self.inputs[name] = @current_multiple_input
      end
      @current_multiple_input = nil
    end

    def object_name(name)
      alias_method name, :object
    end
  end

  def initialize(params = {})
    self.object = params[:object]

    # because we're iterating through all inputs, not just the ones passed
    # to the constructor, this will set any missing inputs to default or nil
    self.class.inputs.each do |name, options|
      send "#{name}=", resolve_value(params[name], options)
    end

    super()
  end

  # collects values of the form into a hash
  def values
    @values ||= inputs.reduce({}) do |values, (name, options)|
      values[name] = {
        value: send(name),
        choices: (eval(options[:choices].to_s) if options[:choices])
      }

      #if options[:inputs]
      #  options[:inputs].each do |input, input_options|
      #    values[name][input] = {choices: eval(input_options[:choices].to_s)} if input_options[:choices]
      #    or
      #    values[name][:value][input][:choices] = eval(input_options[:choices].to_s) if input_options[:choices]
      #  end
      #end

      values
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

  def resolve_value(params, options)
    if options[:group]
      resolve_nested_values(params, options)
    elsif options[:multiple]
      (params || []).map do |member_params|
        resolve_nested_values(member_params, options)
      end
    elsif !params and default = options[:default]
      if [TrueClass, FalseClass, Integer, Fixnum, Float, Time, String, Array, Hash].include?(default.class)
        default
      else
        send(default)
      end
    elsif options[:type] == :boolean
      !!params
    elsif !params
      nil
    elsif options[:type] == Integer
      params.to_i
    elsif options[:type] == Float
      params.to_f
    else
      params.is_a?(Hash) ? Deckhand::OpenStructWithoutTable.new(params) : params
    end
  end

  def resolve_nested_values(params, options)
    params = ActiveSupport::HashWithIndifferentAccess.new(params || {})
    values = options[:inputs].reduce({}) do |values, (input, input_options)|
      values[input] = resolve_value(params[input.to_sym], input_options)
      values
    end
    Deckhand::OpenStructWithoutTable.new(values)
  end
end