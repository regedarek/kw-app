module Api
  class UsersController < Api::BaseController
    def index
      users = Db::User.select(:id, :first_name, :last_name)
      
      render json: users
    end
  end
end
