Rails.application.routes.draw do
  scope module: 'training' do
    namespace :activities do
      namespace :api do
        resources :mountain_route_points
        resources :mountain_routes, only: :index
        resources :boars, only: :index
      end
      resources :ski_routes
      resources :contracts
      resources :user_contracts, only: [:create, :destroy]

      match 'heart', to: 'hearts#heart', via: :post
      match 'unheart', to: 'hearts#unheart', via: :delete
    end

    namespace :questionare do
      resources :snw_profiles, only: [:new, :create]
    end

    get 'wydarzenia/:id' => 'supplementary/courses#show', as: 'training_supplementary_course_record'

    namespace :supplementary do
      namespace :api do
        resources :courses, only: :index
      end
      resources :courses do
        resources :packages, only: [:new, :create]
        collection do
          get :archived
        end
      end
      resources :sign_ups do
        member do
          put :send_email
          put :cancel_cash_payment
        end
        collection do
          get :cancel
          put :manually
        end
      end
    end
  end

  get 'narciarskie-dziki/kontrakty' => 'training/activities/contracts#index', as: :kontrakty
  get 'przejscia/narciarstwo' => 'training/activities/ski_routes#new', as: :narciarstwo
  get 'przejscia/wspinaczka' => 'activities/mountain_routes#new', as: :wspinaczka
  get 'wydarzenia/narciarskie' => 'training/supplementary/courses#index', defaults: { category: 'snw' }, as: :ski_events
  get 'wydarzenia/wspinaczkowe' => 'training/supplementary/courses#index', defaults: { category: 'sww' }, as: :climbing_events
  get 'wydarzenia/webinary' => 'training/supplementary/courses#index', defaults: { category: 'web' }, as: :web_events
  get 'wydarzenia' => 'training/supplementary/courses#index', as: :wydarzenia
  get 'wydarzenia/*id' => 'training/supplementary/courses#show', as: :polish_event
  get 'wydarzenia/*slug' => 'training/supplementary/courses#show', as: :polish_event_slug
  get 'wydarzenie/wypisz/*code' => 'training/supplementary/sign_ups#cancel', as: :polish_event_cancel
end
