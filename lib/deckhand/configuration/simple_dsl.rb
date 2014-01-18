class Deckhand::Configuration::SimpleDSL

  def initialize(options = {}, &block)
    @store = {}
    @options = {singular: [], defaults: {}}.merge options
    @options[:defaults].each {|key, value| @store[key] = value }
    instance_eval &block
  end

  def method_missing(sym, *args, &block)
    if args.none? && !block
      @store[sym]
    else
      if @options[:singular].include? sym
        @store[sym] = merged_args(args, block, true)
      else
        # allow keywords to be called multiple times & accumulate args
        @store[sym] ||= []
        @store[sym] << merged_args(args, block, false)
      end
    end
  end

  def merged_args(args, block, unwrap)
    if args.any? && block
      [args, block].flatten(1)
      args.first
    elsif block
      block
    elsif args.size == 1 && unwrap
      args.first
    else
      args
    end
  end

end