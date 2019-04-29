Rails.application.routes.draw do
  scope module: 'email_center' do
    namespace :api do
      resources :emails, only: [] do
        collection do
          post :delivered
        end
      end
    end
  end
end
