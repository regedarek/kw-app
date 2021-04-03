Rails.application.routes.draw do
  mount_griddler

  scope module: 'email_center' do
    namespace :admin do
      resources :email_records, only: [:destroy]
    end
    namespace :api do
      resources :emails, only: [] do
        collection do
          post :delivered
        end
      end
    end
  end
end
