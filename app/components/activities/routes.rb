Rails.application.routes.draw do
  scope module: 'activities' do
    #resources :mountain_routes, only: :index
    resources :competitions
    namespace :api do
      resources :routes, only: [] do
        member do
          get :season
        end
      end
      resources :competitions do
        collection do
          get :skimo
        end
      end
    end
  end

  get "routes" => 'activities/routes#index'
  get "gorskie-dziki/regulamin" => 'activities/routes#gorskie_dziki_regulamin', as: :gorskie_dziki_regulamin
  get "gorskie-dziki" => 'activities/routes#gorskie_dziki', as: :gorskie_dziki
  get "narciarskie-dziki" => 'activities/routes#narciarskie_dziki', as: :narciarskie_dziki
  get "narciarskie-dziki/:year/:month" => 'activities/routes#narciarskie_dziki_month', as: :narciarskie_dziki_month
end
