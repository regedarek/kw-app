Rails.application.routes.draw do
  scope module: 'management' do
    resources :projects
  end
end
