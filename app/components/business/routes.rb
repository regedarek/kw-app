Rails.application.routes.draw do
  namespace :business do
    resources :sign_ups
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
