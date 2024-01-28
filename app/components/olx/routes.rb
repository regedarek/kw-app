Rails.application.routes.draw do
  namespace :olx do
    resources :sale_announcements, path: "ogloszenia"
  end
end
