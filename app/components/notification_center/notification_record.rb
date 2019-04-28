module NotificationCenter
  class NotificationRecord < ActiveRecord::Base
    self.table_name = 'notifications'

    scope :unread, -> { where(read_at: nil) }

    belongs_to :recipient, class_name: 'Db::User'
    belongs_to :actor, class_name: 'Db::User'
    belongs_to :notifiable, polymorphic: true
  end
end
