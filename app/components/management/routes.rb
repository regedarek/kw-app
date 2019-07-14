Rails.application.routes.draw do
  scope module: 'management' do
    resources :projects, path: 'projekty'
    scope module: 'voting' do
      resources :cases, path: 'glosowania' do
        member do
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
