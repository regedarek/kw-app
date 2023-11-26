Rails.application.routes.draw do
  get "/osemka/:year/zgloszenie" => "yearly_prize/editions/requests#new", as: :yearly_prize
  post "/osemka/:year/zgloszenie" => "yearly_prize/editions/requests#create", as: :yearly_prize_requests
end
