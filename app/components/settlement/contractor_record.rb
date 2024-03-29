# == Schema Information
#
# Table name: contractors
#
#  id              :bigint           not null, primary key
#  contact_name    :string
#  description     :text
#  email           :string
#  logo            :string
#  name            :string
#  nip             :string
#  phone           :string
#  profession_type :integer          default("no_profession"), not null
#  reason_type     :integer          default("both"), not null
#  www             :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
module Settlement
  class ContractorRecord < ActiveRecord::Base
    has_paper_trail
    self.table_name = 'contractors'

    mount_uploader :logo, Settlement::ContractorLogoUploader

    has_many :courses, class_name: 'Business::CourseRecord', foreign_key: :instructor_id
    has_many :contracts, class_name: 'Settlement::ContractRecord', foreign_key: :contractor_id
    has_many :sponsorship_requests, class_name: 'Marketing::SponsorshipRequestRecord', foreign_key: :contractor_id
    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'

    validates :name, presence: true

    enum reason_type: [:both, :contracts, :sponsor]
    enum profession_type: [:no_profession, :instructor]

    def display_name
      contact_name
    end
  end
end
