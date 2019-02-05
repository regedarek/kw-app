require 'active_model'

module Admin
  class ItemsForm
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    attr_accessor :display_name, :description, :rentable, :owner, :cost, :rentable_id

    validates :display_name, presence: { message: 'nie moze byc pusty'}

    def params
      ActiveSupport::HashWithIndifferentAccess.new(
        display_name: display_name, cost: cost, description: description, rentable: rentable, owner: owner.to_i,
        rentable_id: rentable_id
      )
    end
  end
end
