Rails.application.routes.draw do
  scope module: 'messaging' do
    namespace :api do
      resources :comments, only: :index
    end
    resources :comments
    resources :conversations do
      post :add_participant, on: :member

      resources :messages
    end
  end

  get 'wiadomosci' => 'messaging/conversations#index'
end
