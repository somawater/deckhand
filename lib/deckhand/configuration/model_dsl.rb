require 'deckhand/configuration/simple_dsl'

class Deckhand::Configuration::ModelDSL < Deckhand::Configuration::SimpleDSL

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

end