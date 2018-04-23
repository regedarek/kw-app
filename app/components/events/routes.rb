Rails.application.routes.draw do
  get "zawody/*name" => 'events/competitions/sign_ups#index'

  scope module: 'events' do
    resources :competitions, only: [] do
      resources :sign_ups, controller: 'competitions/sign_ups'
    end

    namespace :admin do
      resources :competitions do
        member do
          put :toggle_closed
        end
      end
    end
  end
end
