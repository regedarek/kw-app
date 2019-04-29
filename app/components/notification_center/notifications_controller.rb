module NotificationCenter
  class NotificationsController < ApplicationController
    append_view_path 'app/components'
    before_action :authenticate_user!

    def index
      notifications = NotificationCenter::NotificationRecord.includes([:actor, :notifiable]).where(recipient: current_user).recent

      render json: notifications.map { |record| NotificationCenter::Notification.from_record(record) }
    end

    def mark_as_read
      notifications = NotificationCenter::NotificationRecord.includes([:actor, :notifiable]).where(recipient: current_user).unread

      notifications.update_all read_at: Time.zone.now
      render json: { success: true }
    end
  end
end
