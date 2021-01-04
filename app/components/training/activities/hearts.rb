module Training
  module Activities
    class Hearts
      def initialize(user)
        @user = user
      end
      # creates a new heart row with post_id and user_id
      def heart!(route)
        @user.hearts.create!(mountain_route_id: route.id) unless heart?(route)
      end

      # destroys a heart with matching post_id and user_id
      def unheart!(route)
        heart = @user.hearts.includes(:user).find_by(mountain_route_id: route.id)
        heart.destroy!
      end

      # returns true of false if a post is hearted by user
      def heart?(route)
        return false unless @user.present?

        @user.hearts.includes(:user).find_by(mountain_route_id: route.id)
      end
    end
  end
end
