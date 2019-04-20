Rails.application.routes.draw do
  scope module: 'activities' do
    #resources :mountain_routes, only: :index
  end

  get "routes" => 'activities/routes#index'
  get "gorskie-dziki/regulamin" => 'activities/routes#gorskie_dziki_regulamin', as: :gorskie_dziki_regulamin
  get "gorskie-dziki" => 'activities/routes#gorskie_dziki', as: :gorskie_dziki
end
