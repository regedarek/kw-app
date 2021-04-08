module Settlement
  class ContractorRecord < ActiveRecord::Base
    has_paper_trail
    self.table_name = 'contractors'

    mount_uploader :logo, Settlement::ContractorLogoUploader

    has_many :courses, class_name: 'Business::CourseRecord', foreign_key: :instructor_id
    has_many :contracts, class_name: 'Settlement::ContractRecord', foreign_key: :contractor_id
    has_many :sponsorship_requests, class_name: 'Marketing::SponsorshipRequestRecord', foreign_key: :contractor_id
    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'

    enum reason_type: [:both, :contracts, :sponsor]
    enum profession_type: [:no_profession, :instructor]
  end
end
