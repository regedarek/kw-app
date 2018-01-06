Rails.application.routes.draw do
  scope module: 'events' do
    namespace :admin do
      resources :competitions
    end
  end
end
