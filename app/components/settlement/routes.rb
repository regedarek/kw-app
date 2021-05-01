Rails.application.routes.draw do
  scope module: 'settlement' do
    namespace :api do
      resources :contractors
    end
    namespace :admin do
      resources :contractors
      resources :project_items, only: [:create, :update]
      resources :incomes, only: :create
      resources :projects do
        member do
          put :close
        end
      end
      resources :contracts do
        collection do
          get :history
        end
        member do
          get :download_attachment
          put :accept
          put :prepayment
          put :finish
        end
      end
    end
  end

  get "rozlicz" => 'settlement/admin/contracts#new'
  get "rozliczenia" => 'settlement/admin/contracts#index'
  get "rozliczenia/analiza/:year" => 'settlement/admin/contracts#analiza'
end
