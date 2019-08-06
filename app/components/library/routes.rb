Rails.application.routes.draw do
  scope module: 'library' do
    namespace :admin do
      resources :tags
    end
  end

  namespace :library do
    resources :items
    resources :authors, only: :show
  end

  get 'biblioteka', to: 'library/items#index', as: :biblioteka
  get 'tagi', to: 'library/admin/tags#index', as: :tagi
  get 'biblioteka/:id', to: 'library/items#show', as: :ksiazka
  get 'biblioteka/autorzy/:id', to: 'library/authors#show', as: :autor
end
