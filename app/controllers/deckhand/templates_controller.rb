class Deckhand::TemplatesController < Deckhand::BaseController

  layout false
  helper 'deckhand/templates'

  def index
    @model = Deckhand.config.models_by_name[params[:model]]
    if @action = params[:act]
      @form_class = Deckhand.config.for_model(@model).action_form_class(@action)
      render 'deckhand/templates/action_form'
    else
      render 'deckhand/templates/card'
    end
  end

end