module Activities
  class SeasonLeaderSerializer < ActiveModel::Serializer
    attributes :id, :gender, :leader, :total_mountain_routes_length, :training_contracts_length, :total_length, :last_activity

    def leader
      UserManagement::UserSerializer.new(user)
    end

    def training_contracts_length
      start_day = DateTime.new(@instance_options[:year].to_i - 1, 12, 01)
      end_day = DateTime.new(@instance_options[:year].to_i, 4, 30)

      user.training_user_contracts.where(created_at: start_day..end_day).inject(0) { |sum, contract| sum + contract.contract.score }
    end

    def total_length
      object.total_mountain_routes_length + training_contracts_length
    end

    def last_activity
      Activities::RouteSerializer.new(user.mountain_routes.order(:created_at).last)
    end

    def user
      Db::User.find(object.id)
    end
  end
end
