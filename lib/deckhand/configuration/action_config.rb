class Deckhand::Configuration::ActionConfig
  attr_reader :action, :label

  def initialize(options = {})
    @action = options.delete(:action)
    @label = options.delete(:label)
  end
end