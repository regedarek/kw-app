Rails.application.routes.draw do
  scope module: 'shop' do
    resources :items
  end

  get 'sklepik' => 'shop/items#index'
  get 'sklepik/:id' => 'shop/items#show'
end
