# == Schema Information
#
# Table name: notifications
#
#  id              :bigint           not null, primary key
#  action          :string
#  notifiable_type :string           not null
#  read_at         :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  actor_id        :integer
#  notifiable_id   :integer          not null
#  recipient_id    :integer
#
module NotificationCenter
  class NotificationRecord < ActiveRecord::Base
    self.table_name = 'notifications'

    scope :unread, -> { where(read_at: nil) }
    scope :recent, -> { order(created_at: :desc).limit(5) }

    belongs_to :recipient, class_name: 'Db::User'
    belongs_to :actor, class_name: 'Db::User'
    belongs_to :notifiable, polymorphic: true
  end
end
