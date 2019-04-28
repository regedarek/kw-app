require 'json'
require 'dry-types'
require 'dry-struct'

module Types
  include Dry::Types.module
end

module NotificationCenter
  class Notification < Dry::Struct
    attribute :id, Types::Strict::Integer
    attribute :unread, Types::Strict::Bool
    attribute :template, Types::Strict::String

    class << self
      include Rails.application.routes.url_helpers

      def from_record(record)
        ApplicationController.append_view_path Rails.root.join('app', 'components', 'notification_center')
        new(
          id: record.id,
          unread: !record.read_at?,
          template: ApplicationController.render(partial: "notifications/#{record.notifiable_type.demodulize.underscore.pluralize}/#{record.action}", locals: { notification: record }, formats: [:html]).html_safe
        )
      end
    end
  end
end
