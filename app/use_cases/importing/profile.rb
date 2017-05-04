module Importing
  class Profile
    include ActiveModel::Model
    include AttributedObject::Strict

    attribute :kw_id, :integer
    attribute :first_name, :string
    attribute :last_name, :string
    attribute :email, :string
    attribute :phone, :string
    attribute :birth_date, :string
    attribute :birth_place, :string
    attribute :pesel, :string
    attribute :city, :string
    attribute :postal_code, :string
    attribute :main_address, :string
    attribute :optional_address, :string
    attribute :recommended_by, ArrayOf(:string)
    attribute :acomplished_courses, ArrayOf(:string)
    attribute :main_discussion_group, :string
    attribute :sections, ArrayOf(:string)
  end
end
