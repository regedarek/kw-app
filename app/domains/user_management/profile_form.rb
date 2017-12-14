require 'form_object'

module UserManagement
  class ProfileForm < FormObject
    attribute :first_name, :string
    attribute :last_name, :string
    attribute :email, :string
    attribute :birth_date, :string
    attribute :birth_place, :string
    attribute :city, :string
    attribute :pesel, :string
    attribute :postal_code, :string
    attribute :main_address, :string
    attribute :optional_address, :string
    attribute :phone, :string
    attribute :recommended_by, ArrayOf(:string), default: []
    attribute :acomplished_courses, ArrayOf(:string), default: []
    attribute :main_discussion_group, :boolean
    attribute :sections, ArrayOf(:string), default: []
    attribute :terms_of_service, :boolean, default: false

    validates :first_name, :last_name, :email, :pesel, :birth_date, :birth_place,
              :city, :postal_code, :acomplished_courses, :phone, :main_address, presence: true
    validates :terms_of_service, acceptance: true
    validate :birth_date_is_to_young
    validate :email_uniq

    def birth_date_is_to_young
      errors.add(:base, "Musisz mieć przynajmniej 16 lat by dołączyć do klubu") if birth_date >= 16.years.ago
    end

    def email_uniq
      errors.add(:email, "zostało już zajęte") if Db::Profile.exists?(email: email)
    end

    def self.model_name
      ActiveModel::Name.new(self, nil, "UserManagementProfileForm")
    end
  end
end
