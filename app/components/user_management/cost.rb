require 'attributed_object'

module UserManagement
  class Cost
    include ActiveModel::Model
    include AttributedObject::Strict

    attribute :first_fee, :integer, default: 50
    attribute :year_fee, :integer, default: 100

    def sum
      first_fee + year_fee
    end
  end
end
