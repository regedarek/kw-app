Rails.application.routes.draw do
  scope module: 'management' do
    resources :projects, path: 'projekty'
    scope module: 'voting' do
      resources :cases, path: 'glosowania'
    end
  end
end
