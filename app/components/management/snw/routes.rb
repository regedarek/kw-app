Rails.application.routes.draw do
  scope module: 'management' do
    scope module: 'snw' do
      resources :snw_applies
    end
  end

  get 'snw/zgloszenie' => 'management/snw/snw_applies#new'
  get 'snw/zgloszenie/:id' => 'management/snw/snw_applies#show', as: :snw_apply_page
end
