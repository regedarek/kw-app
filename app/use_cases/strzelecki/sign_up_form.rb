module Strzelecki
  class SignUpForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :name_1, :vege_1, :birth_year_1, :organization_1, :city_1, :email_1, :package_type_1, :phone_1, :gender_1,
                  :name_2, :vege_2, :birth_year_2, :organization_2, :city_2, :email_2, :package_type_2, :phone_2, :gender_2,
                  :single, :remarks, :terms_of_service

    validates :name_1, :birth_year_1, :package_type_1, :email_1, :gender_1,
      presence: true
    validates :name_2, :birth_year_2, :vege_2, :package_type_2, :gender_2,
      presence: true, if: :team?
    validates :package_type_2, inclusion: { in: %w(kw junior standard) }, if: :team?
    validates :phone_1, :phone_2, numericality: { only_integer: true, allow_blank: true }
    validates_acceptance_of :terms_of_service
    validates :birth_year_1, numericality: { greater_than_or_equal_to: 2000 }, if: :junior_one?
    validates :birth_year_2, numericality: { greater_than_or_equal_to: 2000 }, if: :junior_two?

    def self.model_name
      ActiveModel::Name.new(self, nil, "StrzeleckiSignUpForm")
    end

    def junior_one?
      package_type_1 == 'junior'
    end

    def junior_two?
      package_type_2 == 'junior'
    end

    def persisted?
      false
    end

    def team?
      !ActiveRecord::Type::Boolean.new.deserialize(single)
    end

    def params
      HashWithIndifferentAccess.new(
        name_1: name_1, vege_1: vege_1, birth_year_1: birth_year_1, package_type_1: package_type_1,
        name_2: name_2, vege_2: vege_2, birth_year_2: birth_year_2, package_type_2: package_type_2, 
        email_1: email_1, city_1: city_1, organization_1: organization_1, phone_1: phone_1, gender_1: gender_1,
        email_2: email_1, city_2: city_2, organization_2: organization_2, phone_2: phone_2, gender_2: gender_2,
        remarks: remarks, single: single
      )
    end
  end
end
