Rails.application.routes.draw do
  namespace :shop do
    namespace :admin do
      resources :orders, only: [:index, :show] do
        member do
          put :close
        end
      end
      resources :items, only: [:index, :show]
    end
  end
  scope module: 'shop' do
    namespace :api do
      resources :items
      resources :orders, only: :create
    end
    resources :items, path: 'sklepik'
    resources :orders, path: 'zamowienia'
  end

  get 'sklepik' => 'shop/items#index'
  get 'sklepik-admin' => 'shop/items#admin'
  get 'sklepik/:id' => 'shop/items#show'
end
