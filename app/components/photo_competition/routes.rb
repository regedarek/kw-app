Rails.application.routes.draw do
  scope module: 'photo_competition' do
    resources :editions, only: [:show] do
      resources :requests do
        put :accept, on: :member
      end
    end

    namespace :admin do
      resources :editions
    end
  end

  get "konkurs/:edition_id" => 'photo_competition/requests#new'
  get "konkurs/:edition_code/glosowanie" => 'photo_competition/editions#show'
end
