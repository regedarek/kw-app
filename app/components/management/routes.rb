Rails.application.routes.draw do
  scope module: 'management' do
    resources :projects, path: 'projekty'
  end
end
