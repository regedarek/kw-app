Rails.application.routes.draw do
  scope module: 'shop' do
    namespace :api do
      resources :items
    end
    resources :items
    resources :orders
  end

  get 'sklepik' => 'shop/items#index'
  get 'sklepik/:id' => 'shop/items#show'
end
