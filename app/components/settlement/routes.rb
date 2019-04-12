Rails.application.routes.draw do
  scope module: 'settlement' do
    namespace :admin do
      resources :contracts do
        member do
          put :accept
          put :prepayment
        end
      end
    end
  end

  get "rozlicz" => 'settlement/admin/contracts#new'
  get "rozliczenia" => 'settlement/admin/contracts#index'
end
