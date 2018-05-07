Rails.application.routes.draw do
  scope module: 'training' do
    namespace :questionare do
      resources :snw_profiles, only: [:new, :create]
    end

    namespace :supplementary do
      resources :courses
      resources :sign_ups
    end
  end

  get 'wydarzenia' => 'training/supplementary/courses#index'
  get 'wydarzenia/*id' => 'training/supplementary/courses#show', as: :polish_event
end
