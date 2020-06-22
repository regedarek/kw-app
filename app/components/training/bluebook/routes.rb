Rails.application.routes.draw do
  #get "zawody/*name" => 'events/competitions/sign_ups#index'

  scope module: 'training' do
    scope module: 'bluebook' do
      resources :exercises
    end
  end
end
