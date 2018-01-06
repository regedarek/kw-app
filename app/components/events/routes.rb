Rails.application.routes.draw do
  scope module: 'events' do
    resources :competitions, only: [] do
      resources :sign_ups, controller: 'competitions/sign_ups'
    end

    namespace :admin do
      resources :competitions
    end
  end
end
