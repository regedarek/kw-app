scope module: :profile_creation do
  namespace :v2 do
    resources :profiles, only: [ :new, :create ], controller: "profiles"
  end
end

#get 'zgloszenie' => 'profile_creation/v2/profiles#new'
