Rails.application.routes.draw do
  scope module: 'business' do
    resources :courses

    namespace :api do
      resources :courses, only: :index
    end
  end
end
