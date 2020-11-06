module Settlement
  class ContractorRecord < ActiveRecord::Base
    self.table_name = 'contractors'

    has_many :contracts, class_name: 'Settlement::ContractRecord', foreign_key: :contractor_id
    has_many :sponsorship_requests, class_name: 'Marketing::SponsorshipRequestRecord', foreign_key: :contractor_id
    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'

    enum reason_type: [:both, :contracts, :sponsor]
  end
end
