# == Schema Information
#
# Table name: snw_applies
#
#  id             :bigint           not null, primary key
#  attachments    :string
#  avalanche      :boolean          default(FALSE), not null
#  avalanche_date :date
#  courses        :string
#  cv             :string           not null
#  first_aid      :boolean          default(FALSE), not null
#  skills         :string
#  state          :string           default("new"), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  kw_id          :integer          not null
#
module Management
  module Snw
    class SnwApplyRecord < ActiveRecord::Base
      include Workflow
      self.table_name = 'snw_applies'

      mount_uploaders :attachments, Management::AttachmentUploader
      serialize :attachments, JSON

      has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'

      validates :cv, presence: { message: 'Musisz wypełnić narciarskie CV!' }
      validates :kw_id, uniqueness: { message: 'Możesz wysłać tylko jedno zgłoszenie!' }

      workflow_column :state
      workflow do
        state :new do
          event :accept, :transitions_to => :accepted
        end
        state :accepted
      end

      def profile
        Db::Profile.find_by(kw_id: self.kw_id)
      end
    end
  end
end
