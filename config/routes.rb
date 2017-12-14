Rails.application.routes.draw do
  devise_for :users, class_name: 'Db::User', controllers: { registrations: 'registrations', omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    get '/zaloguj', to: 'devise/sessions#new'
    get '/zarejestruj', to: 'devise/registrations#new'
  end

  get '/*id', to: 'membership/fees#show', constraints: lambda{|request|request.env['SERVER_NAME'].match('skladki')}

  namespace :activities do
    resources :mountain_routes
  end

  namespace :training do
    resources :courses
  end

  get '/', to: 'activities/mountain_routes#index', constraints: lambda{|request|request.env['SERVER_NAME'].match('przejscia')}

  namespace :api do
    resources :users, only: [:index]
    resources :payments, only: [] do
      collection do
        post :status
        post :thank_you
      end
    end
  end

  namespace :mas do
    resources :sign_ups, path: 'zapisy', only: [:index, :new, :create]
  end

  resources :events, only: [:index, :show], path: 'wydarzenia'
  resources :profiles, only: [:index, :new, :create, :show] do
    collection do
      get :reactivation
      put :reactivate
    end
  end

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

  resources :users, only: [:show]
  resources :reservations, only: [:index, :new, :create] do
    member do
      delete :delete_item
    end
    collection do
      post :availability
    end
  end

  resources :payments, only: [:index] do
    member do
      get :charge
    end
  end

  namespace :membership, path: 'klub' do
    resources :fees, path: 'skladki', only: [:index, :create]
  end

  namespace :admin do
    get '', to: 'dashboard#index', as: '/'
    resources :events, only: [:new, :create, :show, :destroy]
    resources :profiles do
      member do
        put :accept
      end
    end
    resources :importing, only: [:index] do
      collection do
        post :import
      end
    end
    resources :users, only: [:index, :create] do
      member do
        get :make_admin
        get :cancel_admin
        get :make_curator
        get :cancel_curator
      end
    end
    resources :competitions
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
  end

  get 'mas' => 'mas/sign_ups#new'
  get 'zarezerwuj' => 'reservations#new', as: :reserve
  get 'zgloszenie' => 'profiles#new'
  get 'reaktywacja' => 'profiles#reactivation'
  get 'przejscia' => 'activities/mountain_routes#index'
  get 'pages/home' => 'pages#show', id: 'home'
  get 'pages/rules' => 'pages#show', id: 'rules'
  get "pages/*id" => 'pages#show', as: :page, format: false

  root to: 'pages#show', id: 'home'
end
