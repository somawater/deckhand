class Deckhand::TemplatesController < Deckhand::BaseController

  layout false
  helper 'deckhand/templates'

  def index
    @model = Deckhand.config.models_by_name[params[:model]]
  end

end