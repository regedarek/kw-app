Rails.application.routes.draw do
  scope module: 'management' do
    scope module: 'snw' do
      resources :snw_applies, only: [:new, :index, :create, :show]
    end
  end

  get 'snw/zgloszenie' => 'management/snw/snw_applies#new'
end
