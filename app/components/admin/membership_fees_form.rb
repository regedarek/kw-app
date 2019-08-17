require 'active_model'

module Admin
  class MembershipFeesForm
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    attr_accessor :kw_id, :year, :plastic

    validates :kw_id, :year, presence: { message: 'nie moze byc pusty'}
    validate :check_uniqueness_of_year

    def params
      ActiveSupport::HashWithIndifferentAccess.new(
        kw_id: kw_id, year: year, plastic: plastic, cost: cost
      )
    end

    def cost
      if plastic
        110
      else
        100
      end
    end

    def check_uniqueness_of_year
      errors.add(:year, 'na ten rok juz istnieje') if user.present? && user.membership_fees.find_by(year: year).present?
    end

    def user
      Db::User.find_by(kw_id: kw_id)
    end
  end
end
