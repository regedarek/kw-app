Rails.application.routes.draw do
  #get "zawody/*name" => 'events/competitions/sign_ups#index'

  scope module: 'blog' do
    namespace :api do
      resources :authors
      resources :dashboard
    end
  end
end
