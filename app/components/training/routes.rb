Rails.application.routes.draw do
  scope module: 'training' do
    namespace :questionare do
      resources :snw_profiles, only: [:new, :create]
    end

    namespace :supplementary do
      resources :courses
    end
  end
end
