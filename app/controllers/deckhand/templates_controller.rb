class Deckhand::TemplatesController < Deckhand::BaseController

  layout false
  helper 'deckhand/templates'

  def index
    @model = params[:model]

    case params[:type]
    when 'card'
      render 'deckhand/templates/card'

    when 'action'
      form_class = model_config.action_form_class(params[:act])
      @inputs = form_class.inputs
      render 'deckhand/templates/modal_form'

    when 'edit'
      @inputs = model_config.fields_to_edit
      if edit_fields = params[:edit_fields]
        @inputs = @inputs.reject {|name, options| !edit_fields.include? name.to_s }
      end
      render 'deckhand/templates/modal_form'

    else
      raise "unknown type: #{params[:type]}"
    end
  end

end