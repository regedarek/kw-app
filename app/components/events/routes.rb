Rails.application.routes.draw do
  get 'mrozne/zapisy', to: 'events/competitions/sign_ups#index', competition_id: Events::Db::CompetitionRecord.find_by(edition_sym: 'mrozne_2018').try(:id)
  get 'strzelecki/zapisy', to: 'events/competitions/sign_ups#index', competition_id: Events::Db::CompetitionRecord.find_by(edition_sym: 'strzelecki_2018').try(:id)
  scope module: 'events' do
    resources :competitions, only: [] do
      resources :sign_ups, controller: 'competitions/sign_ups'
    end

    namespace :admin do
      resources :competitions
    end
  end
end
