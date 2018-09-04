Rails.application.routes.draw do
  scope module: 'photo_competition' do
    resources :editions, only: [] do
      resources :requests
    end

    namespace :admin do
      resources :editions
    end
  end

  get "konkurs/:edition_id" => 'photo_competition/requests#new'
end
