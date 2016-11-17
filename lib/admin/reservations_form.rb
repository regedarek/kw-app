require 'active_model'

module Admin
  class ReservationsForm
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    attr_accessor :kw_id, :start_date, :end_date, :description

    validates :kw_id, presence: { message: 'nie moze byc pusty'}

    def params
      HashWithIndifferentAccess.new(
        user_id: user.id,
        start_date: start_date_of_the_week,
        end_date: end_date_of_the_week,
        description: description
      )
    end

    def start_date_of_the_week
      start_date.to_date.at_beginning_of_week(:thursday)
    end

    def end_date_of_the_week
      end_date.to_date.at_end_of_week(:thursday)
    end

    def user
      Db::User.find_by(kw_id: kw_id)
    end
  end
end
