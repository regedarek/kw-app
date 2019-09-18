Rails.application.routes.draw do
  scope module: 'management' do
    scope module: 'snw' do
      resources :snw_applications, only: [:index, :create]
    end
  end
end
