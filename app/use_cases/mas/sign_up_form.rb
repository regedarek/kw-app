module Mas
  class SignUpForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :name_1, :birth_year_1, :organization_1, :city_1, :email_1, :package_type_1, :phone_1, :gender_1, :tshirt_size_1,
                  :name_2, :birth_year_2, :organization_2, :city_2, :email_2, :package_type_2, :phone_2, :gender_2, :tshirt_size_2,
                  :remarks, :terms_of_service, :kw_id_1, :kw_id_2

    validates :name_1, :birth_year_1, :package_type_1, :email_1, :gender_1, :tshirt_size_1,
      presence: true
    validates :name_2, :birth_year_2, :package_type_2, :gender_2, :tshirt_size_2,
      presence: true
    validates :package_type_1, :package_type_2, inclusion: { in: %w(kw standard) }
    validates :phone_1, :phone_2, numericality: { only_integer: true, allow_blank: true }
    validates_acceptance_of :terms_of_service
    validates :kw_id_1, presence: true, if: proc { package_type_1 == 'kw' }
    validates :kw_id_2, presence: true, if: proc { package_type_2 == 'kw' }
    validate :kw_id_1_fee_check, if: proc { package_type_1 == 'kw' }
    validate :kw_id_2_fee_check, if: proc { package_type_2 == 'kw' }

    def kw_id_1_fee_check
      fee = Db::Membership::Fee.find_by(kw_id: kw_id_1, year: 2017)
      unless fee.present? && fee.payment.present? && fee.payment.paid?
        errors.add(:kw_id_1, "brak opłaconej składki dla numeru klubowego #{kw_id_1}")
      end
    end

    def kw_id_2_fee_check
      fee = Db::Membership::Fee.find_by(kw_id: kw_id_2, year: 2017)
      unless fee.present? && fee.payment.present? && fee.payment.paid?
        errors.add(:kw_id_2, "brak opłaconej składki dla numeru klubowego #{kw_id_2}")
      end
    end

    def self.model_name
      ActiveModel::Name.new(self, nil, "MasSignUpForm")
    end

    def persisted?
      false
    end

    def params
      HashWithIndifferentAccess.new(
        name_1: name_1, birth_year_1: birth_year_1, package_type_1: package_type_1, tshirt_size_1: tshirt_size_1,
        name_2: name_2, birth_year_2: birth_year_2, package_type_2: package_type_2, tshirt_size_2: tshirt_size_2,
        email_1: email_1, city_1: city_1, organization_1: organization_1, phone_1: phone_1, gender_1: gender_1,
        email_2: email_2, city_2: city_2, organization_2: organization_2, phone_2: phone_2, gender_2: gender_2,
        remarks: remarks, kw_id_1: kw_id_1, kw_id_2: kw_id_2
      )
    end
  end
end
