Deckhand::Engine.routes.draw do
  scope module: 'deckhand' do
    root to: 'main#index'
    resource :data do
      get 'search', :on => :collection, :as => :search
      get 'form', :on => :collection, :as => :form
      put 'act'
    end
    resources :templates, only: [:index]
  end
end
