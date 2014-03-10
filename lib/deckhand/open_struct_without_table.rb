require 'ostruct'
require 'active_support/core_ext'

class Deckhand::OpenStructWithoutTable < OpenStruct
  def as_json(options = nil)
    @table.as_json(options)
  end
end