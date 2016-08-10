require 'active_model'

module Admin
  class ItemsForm
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    attr_accessor :name, :description, :rentable, :owner

    validates :name, presence: { message: 'nie moze byc pusty'}

    def params
      HashWithIndifferentAccess.new(
        name: name, description: description, rentable: rentable, owner: owner.to_i
      )
    end
  end
end
