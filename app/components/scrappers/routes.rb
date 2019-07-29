Rails.application.routes.draw do
  scope module: 'scrappers' do
    resources :scrappers, only: :index
    namespace :api do
      resources :pogodynka, only: [:index]
    end
  end
end
