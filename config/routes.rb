Deckhand::Engine.routes.draw do
  scope module: 'deckhand' do
    root to: 'main#index'
    resource :data do
      get 'search', :on => :collection, :as => :search
    end
    resources :templates, only: [:index]
  end
end
