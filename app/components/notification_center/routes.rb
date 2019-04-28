Rails.application.routes.draw do
  scope module: 'notification_center' do
    resources :notifications, only: [:index] do
      collection do
        post :mark_as_read
      end
    end
  end
end
