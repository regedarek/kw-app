require 'active_model'

module Admin
  class MembershipFeesForm
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    attr_accessor :kw_id, :year

    validates :kw_id, :year, presence: { message: 'nie moze byc pusty'}
    validate :check_uniqueness_of_year

    def params
      HashWithIndifferentAccess.new(
        kw_id: kw_id, year: year
      )
    end

    def check_uniqueness_of_year
      errors.add(:year, 'na ten rok juz istnieje') if user.present? && user.membership_fees.find_by(year: year).present?
    end

    def user
      Db::User.find_by(kw_id: kw_id)
    end
  end
end
