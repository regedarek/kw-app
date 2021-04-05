require 'sidekiq/web'
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

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  get 'wiadomosci' => 'messaging/conversations#index'
  get 'wypozyczalnia/regulamin' => 'pages#show', id: 'rules'
  get 'serwis-narciarski/regulamin' => 'pages#show', id: 'rules'
  get 'wydarzenia/regulamin' => 'pages#show', id: 'rules'
  get 'glosowania/dane-osobowe' => 'pages#show', id: 'rules'
  get 'glosowania/instrukcja' => 'pages#show', id: 'rules'
  get 'narciarskie-dziki/regulamin' => 'pages#show', id: 'rules'
  get 'konkurs_kasprzyka/regulamin' => 'pages#show', id: 'rules'
  get 'instrukcje/wydarzenia' => 'pages#show', id: 'rules'
  get 'kontakty' => 'pages#show', id: 'kontakty'
  get '/wydarzenia/webinary', to: redirect { |path_params, req| "/supplementary/courses?category=web" }
  get '/marketing', to: redirect { |path_params, req| "/sponsorship_requests" }

  load Rails.root.join("app/components/events/routes.rb")
  load Rails.root.join("app/components/shop/routes.rb")
  load Rails.root.join("app/components/storage/routes.rb")
  load Rails.root.join("app/components/marketing/routes.rb")
  load Rails.root.join("app/components/training/bluebook/routes.rb")
  load Rails.root.join("app/components/scrappers/routes.rb")
  load Rails.root.join("app/components/notification_center/routes.rb")
  load Rails.root.join("app/components/email_center/routes.rb")
  load Rails.root.join("app/components/activities/routes.rb")
  load Rails.root.join("app/components/messaging/routes.rb")
  load Rails.root.join("app/components/management/routes.rb")
  load Rails.root.join("app/components/membership/admin/routes.rb")
  load Rails.root.join("app/components/training/routes.rb")
  load Rails.root.join("app/components/charity/routes.rb")
  load Rails.root.join("app/components/photo_competition/routes.rb")
  load Rails.root.join("app/components/settlement/routes.rb")
  load Rails.root.join("app/components/user_management/routes.rb")
  load Rails.root.join("app/components/library/routes.rb")
  load Rails.root.join("app/components/business/routes.rb")
  load Rails.root.join("app/components/management/snw/routes.rb")
  load Rails.root.join("app/components/blog/routes.rb")

  resources :photos, only: :index

  namespace :activities, path: '/' do
    resources :mountain_routes, path: 'przejscia' do
      collection do
        get 'photos/:year/:month', to: 'mountain_routes#photos'
      end
      member do
        put :hide
      end
    end
  end

  namespace :api do
    resources :users, only: [:show]
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
      post :refund
      put :mark_as_paid
      get :charge
    end
  end

  namespace :membership, path: 'klub' do
    resources :fees, path: 'skladki', only: [:index, :create]
  end

  namespace :admin do
    get '', to: 'dashboard#index', as: '/'

    resources :versions, only: :index do
      member do
        post :revert
      end
    end

    resources :profiles do
      collection do
        get :general_meeting
      end
      member do
        put :accept
        put :send_email
      end
    end
    resources :importing, only: [:index] do
      collection do
        post :import
      end
    end
    resources :users do
      member do
        post :become
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

  put 'reservations/items', to: 'reservations/items#update', as: :update_items
  get "klubowicze/:kw_id" => 'users#show', as: :user
  get "klubowicze" => 'users#index', as: :users

  get '/', to: 'activities/mountain_routes#index',
    constraints: lambda { |req| req.env['SERVER_NAME'].match('przejscia') }

  get 'zarezerwuj' => 'reservations#new', as: :reserve
  get 'zgloszenie' => 'profiles#new'
  get 'application' => 'profiles#new', locale: :en

  get 'pages/home' => 'pages#show', id: 'home'
  get 'pages/rules' => 'pages#show', id: 'rules'
  get "pages/*id" => 'pages#show', as: :page, format: false
  get 'admin/dostepy' => 'pages#show', id: 'roles'
  get 'warunki' => 'scrappers/scrappers#index'
  get 'trening/skimo' => 'pages#show', id: 'skimo'

  root to: 'pages#show', id: 'home'
end
