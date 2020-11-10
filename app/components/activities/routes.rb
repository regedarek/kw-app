Rails.application.routes.draw do
  scope module: 'activities' do
    #resources :mountain_routes, only: :index
    resources :competitions
    namespace :api do
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
  get "narciarskie-dziki/regulamin" => 'activities/routes#narciarskie_dziki_regulamin', as: :narciarskie_dziki_regulamin
  get "narciarskie-dziki" => 'activities/routes#narciarskie_dziki', as: :narciarskie_dziki
end
