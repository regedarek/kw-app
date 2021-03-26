module Activities
  class RouteSerializer < ActiveModel::Serializer
    attributes :id, :slug, :area, :peak, :name, :description, :mountains,
      :difficulty, :partners, :contracts, :hearts_count, :length, :route_type,
      :climbing_date, :rating

    belongs_to :user
    has_many :photos

    def contracts
      object.training_contracts.map(&:contract).uniq.map(&:name).to_sentence
    end
  end
end
