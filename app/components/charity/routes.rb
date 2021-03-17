Rails.application.routes.draw do
  scope module: 'charity' do
    resources :donations
    namespace :admin do
      resources :donations, only: :index
    end
  end

  get 'darowizny' => 'charity/donations#new'
  get 'dla-mariusza' => 'charity/donations#new', as: :mariusz
  get 'ksiazka-karola' => 'charity/donations#new'
end
