module Importing
  class MembershipFee
    include ActiveModel::Model
    include AttributedObject::Strict

    attribute :kw_id, :integer
    attribute :year, :integer

    validates :kw_id, :year, presence: true
  end
end
