Rails.application.routes.draw do
  scope module: 'management' do
    resources :projects, path: 'projekty'
    resources :settings, path: 'ustawienia', only: [:index, :edit, :update]
    scope module: 'voting' do
      get 'glosowania/pelnomocnictwo' => 'commissions#new'
      resources :commissions, only: [:new, :create]
      resources :cases, path: 'glosowania' do
        collection do
          get :walne, as: :walne
          get :obecni, as: :obecni
          post :accept, as: :accept
        end
        member do
          resources :votes
          get :approve
          get :abstain
          put :approve_for_all
          put :hide
          get :unapprove
        end
      end
    end
    scope module: 'news' do
      namespace :api do
        resources :informations, only: :index
      end
      resources :informations, path: 'informacje'
    end
  end
end
