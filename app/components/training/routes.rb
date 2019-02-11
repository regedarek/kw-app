Rails.application.routes.draw do
  scope module: 'training' do
    namespace :activities do
      resources :ski_routes

      match 'heart', to: 'hearts#heart', via: :post
      match 'unheart', to: 'hearts#unheart', via: :delete
    end

    namespace :questionare do
      resources :snw_profiles, only: [:new, :create]
    end

    namespace :supplementary do
      resources :courses do
        resources :packages, only: [:new, :create]
        collection do
          get :archived
        end
      end
      resources :sign_ups do
        member do
          put :send_email
        end
        collection do
          get :cancel
          put :manually
        end
      end
    end
  end

  get 'narciarskie-dziki' => 'training/activities/ski_routes#index', as: :dziki
  get 'narciarskie-dziki/regulamin' => 'training/activities/ski_routes#rules', as: :dziki_rules
  get 'przejscia/narciarstwo' => 'training/activities/ski_routes#new', as: :narciarstwo
  get 'przejscia/wspinaczka' => 'activities/mountain_routes#new', as: :wspinaczka
  get 'wydarzenia/narciarskie' => 'training/supplementary/courses#index', defaults: { category: 'snw' }, as: :ski_events
  get 'wydarzenia/wspinaczkowe' => 'training/supplementary/courses#index', defaults: { category: 'sww' }, as: :climbing_events
  get 'wydarzenia' => 'training/supplementary/courses#index', as: :wydarzenia
  get 'wydarzenia/*id' => 'training/supplementary/courses#show', as: :polish_event
  get 'wydarzenia/*slug' => 'training/supplementary/courses#show', as: :polish_event_slug
  get 'wydarzenie/wypisz/*code' => 'training/supplementary/sign_ups#cancel', as: :polish_event_cancel

  authenticated :user, lambda {|u| u&.ski_hater? } do
    get "/przejscia" => redirect("/przejscia?route_type=climbing"), constraints: lambda{ |req| req.params.empty? }
  end
end
