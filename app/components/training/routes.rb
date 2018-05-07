Rails.application.routes.draw do
  scope module: 'training' do
    namespace :questionare do
      resources :snw_profiles, only: [:new, :create]
    end

    namespace :supplementary do
      resources :courses
      resources :sign_ups do
        collection do
          get :cancel
        end
      end
    end
  end

  get 'wydarzenia' => 'training/supplementary/courses#index'
  get 'wydarzenia/*id' => 'training/supplementary/courses#show', as: :polish_event
  get 'wydarzenie/wypisz/*code' => 'training/supplementary/sign_ups#cancel', as: :polish_event_cancel
end
