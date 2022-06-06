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

    def member
      user = Db::User.find_by(kw_id: params[:id])

      if user
        render json: user, serializer: UserManagement::MemberSerializer
      else
        render json: { kw_id: :null, active: false }
      end
    end
  end
end
