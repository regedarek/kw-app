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
              :city, :postal_code, :main_address, presence: true
    validates :terms_of_service, acceptance: true

    def self.model_name
      ActiveModel::Name.new(self, nil, "UserManagementProfileForm")
    end
  end
end
