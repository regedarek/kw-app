Rails.application.routes.draw do
  scope module: 'library' do
    namespace :admin do
      resources :areas
    end
  end

  namespace :library do
    resources :items
    resources :authors, only: :show
  end
end
