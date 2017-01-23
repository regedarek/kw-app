module Strzelecki
  class SignUpForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :names, :email, :team

    validates :names, :email, :team, presence: true

    def self.model_name
      ActiveModel::Name.new(self, nil, "StrzeleckiSignUpForm")
    end

    def persisted?
      false
    end

    def params
      HashWithIndifferentAccess.new(
        names: names, email: email, team: team
      )
    end
  end
end
