module Strzelecki
  class SignUpForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :name_1, :vege_1, :birth_year_1,
                  :name_2, :vege_2, :birth_year_2,
                  :email, :single, :organization, :category_type, :package_type, :remarks

    validates :name_1, :birth_year_1, :email, :category_type, :package_type,
      presence: true
    validates :name_2, :birth_year_2, :vege_2, presence: true, if: :team?

    def self.model_name
      ActiveModel::Name.new(self, nil, "StrzeleckiSignUpForm")
    end

    def persisted?
      false
    end

    def team?
      !ActiveRecord::Type::Boolean.new.deserialize(single)
    end

    def params
      HashWithIndifferentAccess.new(
        name_1: name_1, vege_1: vege_1, birth_year_1: birth_year_1,
        name_2: name_2, vege_2: vege_2, birth_year_2: birth_year_2,
        email: email, single: single, organization: organization,
        category_type: category_type, package_type: package_type, remarks: remarks
      )
    end
  end
end
