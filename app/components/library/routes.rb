Rails.application.routes.draw do
  scope module: 'library' do
    namespace :admin do
      resources :areas
    end
  end
end
