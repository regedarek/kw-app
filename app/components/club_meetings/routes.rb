Rails.application.routes.draw do
  get "prezentacje/zglos" => 'club_meetings/ideas#new'

  scope module: 'club_meetings' do
    resources :ideas
  end
end
