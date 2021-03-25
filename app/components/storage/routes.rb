Rails.application.routes.draw do
  scope module: 'storage' do
    resources :uploads
    namespace :api do
      resources :uploads
    end
  end
end
