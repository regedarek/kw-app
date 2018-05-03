Rails.application.routes.draw do
  devise_for :users,
    class_name: 'Db::User',
    controllers: {
      registrations: 'registrations',
      omniauth_callbacks: 'users/omniauth_callbacks'
    }

  devise_scope :user do
    get '/zaloguj', to: 'devise/sessions#new'
    get '/zarejestruj', to: 'devise/registrations#new'
  end

  namespace :activities do
    resources :mountain_routes
  end

  load Rails.root.join("app/components/events/routes.rb")
  load Rails.root.join("app/components/membership/admin/routes.rb")
  load Rails.root.join("app/components/training/routes.rb")

  namespace :api do
    resources :payments, only: [] do
      collection do
        post :status
        post :thank_you
      end
    end
  end

  resources :profiles, only: [:index, :new, :create, :show] do
    collection do
      get :reactivation
      put :reactivate
    end
  end

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

  get '/', to: 'activities/mountain_routes#index',
    constraints: lambda { |req| req.env['SERVER_NAME'].match('przejscia') }

  get 'zarezerwuj' => 'reservations#new', as: :reserve
  get 'zgloszenie' => 'profiles#new'
  get 'przejscia' => 'activities/mountain_routes#index'
  get 'wydarzenia' => 'training/supplementary/courses#index'
  get 'pages/home' => 'pages#show', id: 'home'
  get 'pages/rules' => 'pages#show', id: 'rules'
  get "pages/*id" => 'pages#show', as: :page, format: false

  root to: 'pages#show', id: 'home'
end
