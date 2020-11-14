Rails.application.routes.draw do
  scope module: 'marketing' do
    resources :sponsorship_requests
    resources :discounts, path: 'rabaty'
  end
end
