require 'form_object'

module UserManagement
  class ProfileForm < FormObject
    attribute :first_name, :string
    attribute :last_name, :string
    attribute :locale, :string, default: 'pl'
    attribute :email, :string
    attribute :birth_date, :string
    attribute :birth_place, :string
    attribute :gender, :string
    attribute :city, :string
    attribute :postal_code, :string
    attribute :main_address, :string
    attribute :optional_address, :string
    attribute :phone, :string
    attribute :photo, :string
    attribute :course_cert, :string
    attribute :recommended_by, ArrayOf(:string), default: []
    attribute :acomplished_courses, ArrayOf(:string), default: []
    attribute :main_discussion_group, :boolean
    attribute :sections, ArrayOf(:string), default: []
    attribute :positions, ArrayOf(:string), default: []
    attribute :terms_of_service, :boolean, default: false
    attribute :plastic, :boolean, default: false

    validates :first_name, :last_name, :gender, :email, :birth_date, :birth_place, :photo,
              :city, :postal_code, :acomplished_courses, :phone, presence: true
    validates :terms_of_service, acceptance: true
    validate :email_uniq
    validate :course_cert_needed?

    def course_cert_needed?
      return true if acomplished_courses.any?{ |course| ["instructors", "other_club", "list"].include?(course) }

      errors.add(:course_cert, "musi zostać dołączone") unless course_cert.presence
    end

    def youth?
      return false unless birth_date

      Date.today.year - birth_date&.to_date&.year <= 26
    end

    def email_uniq
      errors.add(:email, "zostało już zajęte") if Db::Profile.exists?(email: email)
    end

    def self.model_name
      ActiveModel::Name.new(self, nil, "UserManagementProfileForm")
    end
  end
end
