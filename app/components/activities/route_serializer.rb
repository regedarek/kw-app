module Activities
  class RouteSerializer < ActiveModel::Serializer
    attributes :id, :slug, :name, :contracts

    def contracts
      object.training_contracts.map(&:contract).uniq.map(&:name).to_sentence
    end
  end
end
