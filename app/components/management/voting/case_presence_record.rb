module Management
  module Voting
    class CasePresenceRecord < ActiveRecord::Base
      self.table_name = 'case_presences'

      belongs_to :user, class_name: 'Db::User'
      belongs_to :cerber, class_name: 'Db::User', optional: true

      validates :user_id, uniqueness: { scope: :presence_date }
    end
  end
end
