Rails.application.routes.draw do
  scope module: 'management' do
    resources :projects, path: 'projekty'
    scope module: 'voting' do
      resources :cases, path: 'glosowania' do
        member do
          get :approve
          put :approve_for_all
          get :unapprove
        end
      end
    end
  end
end
