Rails.application.routes.draw do
  scope module: 'visiting_card' do
    resources :profiles, only: :show
  end
end
