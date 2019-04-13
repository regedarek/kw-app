Rails.application.routes.draw do
  scope module: 'messaging' do
    resources :comments
  end
end
