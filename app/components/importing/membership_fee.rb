require 'attributed_object'

module Importing
  class MembershipFee
    include ActiveModel::Model
    include AttributedObject::Strict

    attribute :kw_id, :string
    attribute :year, :string
    attribute :pesel, :string

    validates :year, presence: true
  end
end
