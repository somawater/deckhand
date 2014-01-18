class Deckhand::TemplatesController < Deckhand::BaseController

  layout false
  helper 'deckhand/templates'

  def index
    @model = Deckhand.config.models_by_name[params[:model]]

    case params[:type]
    when 'card'
      render 'deckhand/templates/card'

    when 'action'
      form_class = Deckhand.config.for_model(@model).action_form_class(params[:act])
      @inputs = form_class.inputs
      render 'deckhand/templates/modal_form'

    when 'edit'
      @inputs = Deckhand.config.for_model(@model).fields_to_edit
      if edit_fields = params[:edit_fields]
        @inputs.reject! {|name, options| !edit_fields.include? name.to_s }
      end
      render 'deckhand/templates/modal_form'

    else
      render 'deckhand/templates/card'
    end
  end

end