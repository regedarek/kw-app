require 'json'
require 'dry-types'
require 'dry-struct'

module Types
  include Dry::Types.module

  Hash   = Strict::Hash
  String = Strict::String
end

module NotificationCenter
  class Notification < Dry::Struct
    attribute :id, Types::Strict::Integer
    attribute :recipient do
      attribute :id, Types::Strict::Integer
      attribute :display_name, Types::Strict::String
    end
    attribute :actor do
      attribute :id, Types::Strict::Integer
      attribute :display_name, Types::Strict::String
    end
    attribute :notifiable do
      attribute :id, Types::Strict::Integer
      attribute :type, Types::Strict::String
    end
    attribute :action, Types::Strict::String
    attribute :url, Types::Strict::String
    attribute :created_at, Types::JSON::DateTime

    class << self
      include Rails.application.routes.url_helpers
      include ActionDispatch::Routing
      include ApplicationHelper
      def from_record(record)
        new(
          id: record.id,
          recipient: { id: record.recipient.id, display_name: record.recipient.display_name },
          actor: { id: record.actor.id, display_name: record.actor.display_name },
          notifiable: { id: record.notifiable_id, type: record.notifiable_type },
          action: record.action,
          url: url_for(record.notifiable),
          created_at: record.created_at
        )
      end
    end
  end
end
