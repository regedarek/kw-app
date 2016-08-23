require 'active_model'

module Reservations
  class Form
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    attr_accessor :kw_id, :item_ids, :start_date, :end_date

    validates :kw_id, :item_ids, :start_date, :end_date, presence: { message: 'nie moze byc pusty'}

    def params
      HashWithIndifferentAccess.new(
        user_id: user.id,
        item_ids: item_ids,
        start_date: start_date_of_the_week,
        end_date: end_date_of_the_week
      )
    end

    def start_date_of_the_week
      start_date.to_date.at_beginning_of_week(:thursday)
    end

    def end_date_of_the_week
      end_date.to_date
    end

    def user
      Db::User.find_by(kw_id: kw_id)
    end
  end
end
