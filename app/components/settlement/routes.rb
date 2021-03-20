Rails.application.routes.draw do
  scope module: 'settlement' do
    namespace :admin do
      resources :contractors
      resources :projects do
        member do
          put :close
        end
      end
      resources :contracts do
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
