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

    def active
      user = Db::User.find_by(email: params[:email])

      if user
        render json: user, serializer: UserManagement::MemberSerializer
      else
        render json: { active: false }
      end
    end
  end
end
