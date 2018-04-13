Rails.application.routes.draw do
  namespace :membership do
    namespace :admin do
      resources :membership_fees, only: [] do
        collection do
          get :unpaid
        end
      end
    end
  end
end
