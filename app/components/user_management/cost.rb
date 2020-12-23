require 'attributed_object'

module UserManagement
  class Cost
    include ActiveModel::Model
    include AttributedObject::Strict

    attribute :first_fee, :integer, default: 50
    attribute :year_fee, :integer, default: 100
    attribute :plastic, :boolean, default: false

    def sum
      first_fee + year_fee + plastic_cost
    end

    private

    def plastic_cost
      if plastic
        15
      else
        0
      end
    end
  end
end
