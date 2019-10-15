Rails.application.routes.draw do
  scope module: 'business' do
    resources :courses do
      member do
        put :seats_minus
        put :seats_plus
      end
    end

    namespace :api do
      resources :courses, only: :index
    end
  end
end
