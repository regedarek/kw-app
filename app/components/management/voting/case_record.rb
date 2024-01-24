# == Schema Information
#
# Table name: management_cases
#
#  id                  :bigint           not null, primary key
#  acceptance_date     :datetime
#  attachments         :string
#  destrciption        :text
#  doc_url             :string
#  final_voting_result :string
#  hidden              :boolean          default(FALSE), not null
#  hide_votes          :boolean          default(FALSE), not null
#  meeting_type        :integer          default("manage"), not null
#  name                :string           not null
#  number              :string
#  position            :integer
#  public              :boolean          default(FALSE), not null
#  slug                :string           not null
#  state               :string           default("draft"), not null
#  voting_type         :integer          default("document"), not null
#  who_ids             :string           is an Array
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  creator_id          :integer          not null
#
# Indexes
#
#  index_management_cases_on_slug  (slug) UNIQUE
#
module Management
  module Voting
    class CaseRecord < ActiveRecord::Base
      include Workflow
      extend FriendlyId

      enum voting_type: [:document, :members]
      enum meeting_type: [:manage, :circle]

      mount_uploaders :attachments, Management::AttachmentUploader
      serialize :attachments, JSON

      friendly_id :name, use: :slugged
      self.table_name = 'management_cases'

      has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord', dependent: :destroy
      has_many :votes, class_name: 'Management::Voting::VoteRecord', foreign_key: :case_id, dependent: :destroy
      has_many :users, through: :votes, foreign_key: :user_id, dependent: :destroy, source: :user

      workflow_column :state
      workflow do
        state :draft
        state :unactive
        state :voting do
          event :finish, :transitions_to => :finished
        end
        state :finished
        state :archived
      end
    end
  end
end
