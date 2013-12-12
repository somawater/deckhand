Deckhand::Engine.routes.draw do
  scope module: 'deckhand' do
    root to: 'main#index'
    get 'search' => 'search#show'
  end
end
