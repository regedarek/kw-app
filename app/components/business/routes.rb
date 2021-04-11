Rails.application.routes.draw do
  namespace :business do
    resources :course_types, only: [:index]
    resources :conversations, only: [:create] do
      resources :messages, only: [:create]
    end
    resources :payments, only: [] do
      member do
        post :charge
      end
    end
    resources :sign_ups do
      member do
        resources :lists, only: [:new, :create] do
          collection do
            post :ask
          end
        end
        post :send_second
      end
    end
  end
  scope module: 'business' do
    resources :courses do
      collection do
        get :history
      end
      member do
        get :public
        put :seats_minus
        put :seats_plus
      end
    end

    namespace :api do
      resources :courses, only: :index
    end

    get 'zapotrzebowanie/:id' => 'lists#new', as: 'business_list'
    get 'kursy/:id' => 'courses#public', as: 'business_course_record_public'
    get 'courses/:id' => 'courses#show', as: 'business_course_record'
  end
end
