Rails.application.routes.draw do
  namespace :business do
    resources :payments, only: [] do
      member do
        post :charge
      end
    end
    resources :sign_ups do
      member do
        resources :lists, only: [:new, :create]
        post :send_second
      end
    end
  end
  scope module: 'business' do
    resources :courses do
      member do
        get :public
        put :seats_minus
        put :seats_plus
      end
    end

    namespace :api do
      resources :courses, only: :index
    end

    get 'kursy/:id' => 'courses#public', as: 'business_course_record_public'
    get 'courses/:id' => 'courses#show', as: 'business_course_record'
    get 'kursy/narciarskie' => 'courses#index', q: { activity_type_in: [3, 4, 5]}
    get 'kursy/turystyki' => 'courses#index', q: { activity_type_in: [0, 1, 2]}
  end
end
