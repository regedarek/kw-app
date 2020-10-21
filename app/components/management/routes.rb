Rails.application.routes.draw do
  scope module: 'management' do
    resources :projects, path: 'projekty'
    resources :settings, path: 'ustawienia', only: [:index, :edit, :update]
    scope module: 'voting' do
      resources :cases, path: 'glosowania' do
        collection do
          get :walne, as: :walne
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
      resources :informations, path: 'informacje', only: :index
    end
  end
end
