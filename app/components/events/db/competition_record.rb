module Events
  module Db
    class CompetitionRecord < ActiveRecord::Base
      self.table_name = 'competitions'

      has_many :sign_ups, class_name: 'Events::Db::SignUpRecord'
    end
  end
end
