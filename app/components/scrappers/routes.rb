Rails.application.routes.draw do
  scope module: 'scrappers' do
    resources :scrappers, only: :index
  end
end
