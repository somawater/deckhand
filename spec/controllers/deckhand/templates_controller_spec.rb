require 'spec_helper'

describe Deckhand::TemplatesController do
  describe 'GET index' do
    let(:form_class) do
      double('form_class',
        inputs: 'some inputs',
        view: form_class_view)
    end

    let(:form_class_view) { nil }

    let(:model_config) do
      double('model_config', fields_to_edit: 'fields to edit')
    end

    let(:params) do
      {
        use_route: :deckhand,
        type: type_param,
        model: 'SomeModel'
      }
    end

    before do
      subject.stub(:form_class) { form_class }
      subject.stub(:model_config) { model_config }
      get :index, params
    end

    shared_examples 'rendering the modal_form view' do
      it 'renders the modal_form view' do
        expect(response).to render_template('deckhand/templates/modal_form')
      end

      context 'if the form_class has a custom view defined' do
        let(:form_class_view) { 'some custom view' }

        it 'assigns the custom form view' do
          expect(assigns(:view)).to eq form_class.view
        end
      end

      context 'if the form_class does not have a custom view defined' do
        it 'does not assign the view' do
          expect(assigns(:view)).to be_nil
        end
      end
    end

    context 'with type="action"' do
      let(:type_param) { 'action' }

      include_examples 'rendering the modal_form view'
    end

  end
end
