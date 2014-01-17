class Deckhand::Configuration::ModelDSL

  def initialize(options = {}, &block)
    @store = {}

    @options = {singular: [], defaults: {}}.merge options
    @options[:defaults].each {|key, value| @store[key] = value }

    instance_eval &block
  end

  def keyword_with_options(key, *args, &block)
    if args.none?
      @store[key]
    else
      @store[key] ||= []
      if args.last.is_a?(Hash)
        options = args.last
        args[0..-2].each {|a| @store[key] << [a, options] }
      else
        options = block ? {block: block} : {}
        args.each {|a| @store[key] << [a, options] }
      end
    end
  end

  %w[search_on show action].each do |keyword|
    define_method keyword do |*args, &block|
      keyword_with_options(keyword.to_sym, *args, &block)
    end
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