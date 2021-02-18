Rails.application.routes.draw do
  scope module: 'storage' do
    namespace :api do
      resources :uploads
    end
  end
end
