Rails.application.routes.draw do
  devise_for :users, class_name: 'Db::User', controllers: {registrations: 'registrations'}

  get '/', to: 'reservations#new', constraints: lambda{|request|request.env['SERVER_NAME'].match('wypozyczalnia')}
  get '/', to: 'routes#index', constraints: lambda{|request|request.env['SERVER_NAME'].match('przejscia')}
  get '/', to: 'pages#show', id: 'strzelecki', constraints: lambda{|request|request.env['SERVER_NAME'].match('strzelecki')}
  get '/', to: 'auctions#index', constraints: lambda{|request|request.env['SERVER_NAME'].match('kiermasz')}

  get 'pages/home' => 'pages#show', id: 'home'
  get 'pages/rules' => 'pages#show', id: 'rules'
  get "/pages/*id" => 'pages#show', as: :page, format: false
  root to: 'pages#show', id: 'home'

  namespace :api do
    resources :payments, only: [] do
      collection do
        post :status
        post :thank_you
      end
    end
  end

  resources :product_types

  resources :auctions do
    member do
      post :mark_archived
    end
  end
  resources :auction_products do
    member do
      post :mark_sold
    end
  end
  resources :routes
  resources :products
  resources :users, only: [:show]
  resources :reservations, only: [:index, :new, :create] do
    member do
      delete :delete_item
    end
    collection do
      post :availability
    end
  end
  resources :payments, only: [] do
    member do
      post :charge
    end
  end

  namespace :admin do
    get '', to: 'dashboard#index', as: '/'
    resources :users, only: [:index, :create] do
      member do
        get :make_admin
        get :cancel_admin
        get :make_curator
        get :cancel_curator
      end
    end
    resources :membership_fees, only: %w(index create destroy)
    resources :items do
      member do
        put :update_owner
        put :update_editable
        put :toggle_rentable
      end
    end
    resources :reservations, only: %w(index edit update destroy) do
      member do
        put :archive
        put :charge
        put :give
        post :remind
        post :give_warning
        post :give_back_warning
      end
    end
    resources :valleys, only: %w(index create destroy)
    resources :peaks, only: %w(create destroy)
  end
end
