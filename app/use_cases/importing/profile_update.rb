module Importing
  class ProfileUpdate
    include ActiveModel::Model
    include AttributedObject::Strict

    attribute :email, :string
    attribute :acomplished_courses, ArrayOf(:string)
    attribute :sections, ArrayOf(:string)
    attribute :profession, :string
  end
end
