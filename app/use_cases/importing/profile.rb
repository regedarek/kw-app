module Importing
  class Profile
    include ActiveModel::Model
    include AttributedObject::Strict

    attribute :sections, ArrayOf(:string)
  end
end
