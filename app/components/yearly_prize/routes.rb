Rails.application.routes.draw do
  get "/osemka/:year" => "yearly_prize/editions/requests#index", as: :yearly_prize_edition_requests
  get "/osemka/:year/zgloszenie" => "yearly_prize/editions/requests#new", as: :yearly_prize
  post "/osemka/:year/zgloszenie" => "yearly_prize/editions/requests#create", as: :yearly_prize_requests
  get "/osemka/:year/zgloszenie/:request_id" => "yearly_prize/editions/requests#show", as: :yearly_prize_request
end
