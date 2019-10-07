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
