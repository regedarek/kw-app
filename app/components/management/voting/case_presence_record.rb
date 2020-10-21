module Management
  module Voting
    class CasePresenceRecord < ActiveRecord::Base
      self.table_name = 'case_presences'

      belongs_to :user, class_name: 'Db::User'
    end
  end
end
