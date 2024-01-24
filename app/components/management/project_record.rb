# == Schema Information
#
# Table name: projects
#
#  id               :bigint           not null, primary key
#  attachments      :string
#  benefits         :text
#  description      :text
#  estimated_time   :text
#  group_type       :integer          default("kw"), not null
#  know_how         :text
#  name             :string           not null
#  needed_knowledge :text
#  slug             :string
#  state            :string           default("draft")
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  coordinator_id   :integer
#
# Indexes
#
#  index_projects_on_slug  (slug) UNIQUE
#
module Management
  class ProjectRecord < ActiveRecord::Base
    include Workflow
    extend FriendlyId
    friendly_id :name, use: :slugged
    self.table_name = 'projects'

    enum group_type: [:kw, :sww, :snw, :stj]

    mount_uploaders :attachments, Management::AttachmentUploader
    serialize :attachments, JSON

    has_many :project_users, class_name: 'Management::ProjectUsersRecord', foreign_key: :project_id
    has_many :users, through: :project_users, foreign_key: :user_id, dependent: :destroy
    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'
    belongs_to :coordinator, class_name: 'Db::User', foreign_key: :coordinator_id

    def users_names=(ids)
      self.user_ids = ids
    end

    workflow_column :state
    workflow do
      state :draft
      state :unassigned
      state :in_progress
      state :suspended
      state :archived
    end

    attr_reader :users_names
  end
end
