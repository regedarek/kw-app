require 'attributed_object'

module Importing
  class User
    include ActiveModel::Model
    include AttributedObject::Strict

    attribute :kw_id, :integer
    attribute :first_name, :string
    attribute :last_name, :string
    attribute :email, :string
    attribute :phone, :string
    attribute :password, :string

    validates :kw_id, :first_name, :last_name, :email, :password, presence: true
  end
end
