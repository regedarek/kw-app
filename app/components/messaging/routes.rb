Rails.application.routes.draw do
  scope module: 'messaging' do
    resources :comments
    resources :conversations do
      resources :messages
    end
  end
end
