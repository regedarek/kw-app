Rails.application.routes.draw do
  scope module: 'shop' do
    namespace :api do
      resources :items
    end
    resources :items, path: 'sklepik'
    resources :orders, path: 'zamowienia'
  end

  get 'sklepik' => 'shop/items#index'
  get 'sklepik/:id' => 'shop/items#show'
end
