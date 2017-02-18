module UserManagement
  class ProfileForm < FormObject
    attribute :kw_id, :integer, default: nil
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
    attribute :recommended_by, ArrayOf(:string)
    attribute :acomplished_course, ArrayOf(:string)
    attribute :main_discussion_group, :boolean
    attribute :sections, ArrayOf(:string)

    validates :first_name, :last_name, :kw_id, :email, :pesel, :birth_date, :birth_place,
              :city, :postal_code, :main_address, :main_discussion_group, presence: true
  end
end
