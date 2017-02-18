module Importing
  class MountainRoute
    include ActiveModel::Model
    include AttributedObject::Strict

    attribute :route_type, :string
    attribute :name, :string
    attribute :area, :string
    attribute :description, :string
    attribute :difficulty, :string
    attribute :partners, :string
    attribute :time, :string
    attribute :climbing_date, :string
    attribute :rating, :string

    validates :name, :partners, presence: true
  end
end
