Rails.application.routes.draw do
  get 'mrozne/zapisy', to: 'events/competitions/sign_ups#index', competition_id: 4
  get 'strzelecki/zapisy', to: 'events/competitions/sign_ups#index', competition_id: 3

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
