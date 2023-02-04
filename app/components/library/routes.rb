Rails.application.routes.draw do
  scope module: 'library' do
    namespace :admin do
      resources :tags
    end
  end

  get 'biblioteka/wypozyczenia', to: 'library/item_reservations#index', as: :biblioteka_wypozyczenia
  namespace :library do
    resources :items
    resources :authors
    resources :item_reservations do
      member do
        put :return
      end
    end
  end

  get 'biblioteka', to: 'library/items#index', as: :biblioteka
  get 'tagi', to: 'library/admin/tags#index', as: :tagi
  get 'biblioteka/:id', to: 'library/items#show', as: :ksiazka
  get 'biblioteka/autorzy/:id', to: 'library/authors#show', as: :autor
end
