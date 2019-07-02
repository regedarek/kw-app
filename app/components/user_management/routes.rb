Rails.application.routes.draw do
  scope module: 'user_management' do
    resources :profiles, only: [] do
      resources :lists do
        member do
          post :accept
        end
      end
    end
  end
end
