Rails.application.routes.draw do
  scope module: 'library' do
    namespace :admin do
      resources :areas
    end
  end

  namespace :library do
    resources :items
    resources :authors, only: :show
  end

  get 'biblioteka', to: 'library/items#index', as: :biblioteka
  get 'biblioteka/:id', to: 'library/items#show', as: :ksiazka
  get 'biblioteka/autorzy/:id', to: 'library/authors#show', as: :autor
end
