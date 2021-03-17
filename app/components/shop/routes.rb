Rails.application.routes.draw do
  scope module: 'shop' do
    namespace :api do
      resources :items
    end
    resources :items
  end

  get 'sklepik' => 'shop/items#index'
  get 'sklepik/admin' => 'shop/items#admin'
  get 'sklepik/:id' => 'shop/items#show'
end
