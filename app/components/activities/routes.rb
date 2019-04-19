Rails.application.routes.draw do
  scope module: 'activities' do
    #resources :mountain_routes, only: :index
  end

  get "routes" => 'activities/routes#index'
end
