Rails.application.routes.draw do
  devise_for :users, class_name: 'Db::User'

  get 'pages/home' => 'high_voltage/pages#show', id: 'home'

  namespace :api do
    resources :payments, only: [] do
      collection do
        get :status
      end
    end
  end

  resources :routes
  resources :users, only: [:show]
  resources :reservations, only: [:index, :new, :create, :destroy] do
    collection do
      post :availability
    end
  end

  namespace :admin do
    get '', to: 'dashboard#index', as: '/'
    resources :users, only: [:index, :create] do
      member do
        get :make_admin
        get :cancel_admin
      end
    end
    resources :payments, only: %w(index create destroy)
    resources :items, only: %w(index create destroy) do
      member do
        put :update_owner
        post :make_rentable
        post :make_urentable
      end
    end
    resources :reservations, only: %w(index create edit update destroy) do
      member do
        put :update_state
        post :remind
        post :give_warning
        post :give_back_warning
      end
    end
    resources :valleys, only: %w(index create destroy)
    resources :peaks, only: %w(create destroy)
  end
end
