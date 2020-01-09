Rails.application.routes.draw do
  scope module: 'scrappers' do
    resources :scrappers, only: :index
    resources :graphs, only: :index
    namespace :api do
      resources :pogodynka, only: [:index]
      resources :meteoblue, only: [:index]
    end
  end
end
