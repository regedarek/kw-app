module Events
  module Db
    class SignUpRecord < ActiveRecord::Base
      self.table_name = 'events_sign_ups'

      belongs_to :competition, class_name: 'Events::Db::CompetitionRecord'
    end
  end
end
