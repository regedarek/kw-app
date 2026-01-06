# == Schema Information
#
# Table name: management_resolutions
#
#  id          :bigint           not null, primary key
#  description :text
#  name        :string           not null
#  number      :string           not null
#  passed_date :date
#  slug        :string           not null
#  state       :string           default("draft"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
module Management
  class ResolutionRecord < ActiveRecord::Base
    include Workflow
    extend FriendlyId
    friendly_id :name, use: :slugged
    self.table_name = 'management_resolutions'

    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'

    has_many :attachments, as: :uploadable, class_name: 'Storage::UploadRecord'
    accepts_nested_attributes_for :attachments, reject_if: proc { |attributes| attributes[:file].blank? }

    workflow_column :state
    workflow do
      state :draft
      state :published
    end
  end
end
