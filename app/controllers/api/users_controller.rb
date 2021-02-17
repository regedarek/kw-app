module Api
  class UsersController < Api::BaseController
    def index
      users = Db::User.select(:id, :first_name, :last_name)
      render json: users
    end


    def show
      user = Db::User.find(params[:id])

      render json: user, serializer: UserManagement::UserSerializer
    end
  end
end
