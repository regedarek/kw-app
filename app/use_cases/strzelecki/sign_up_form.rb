module Strzelecki
  class SignUpForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :names, :email, :team, :organization, :vege, :birth_year

    validates :names, :email, :team, :birth_year, presence: true

    def self.model_name
      ActiveModel::Name.new(self, nil, "StrzeleckiSignUpForm")
    end

    def persisted?
      false
    end

    def params
      HashWithIndifferentAccess.new(
        names: names, email: email, team: team, organization: organization,
        vege: vege, birth_year: birth_year
      )
    end
  end
end
