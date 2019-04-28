module NotificationCenter
  class NotificationsController < ApplicationController
    before_action :authenticate_user!

    def index
      notifications = NotificationCenter::NotificationRecord.where(recipient: current_user).unread

      render json: notifications.map { |record| NotificationCenter::Notification.from_record(record) }
    end

    def mark_as_read
      notifications = NotificationCenter::NotificationRecord.where(recipient: current_user).unread

      notifications.update_all read_at: Time.zone.now
      render json: { success: true }
    end
  end
end
