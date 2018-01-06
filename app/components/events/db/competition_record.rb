module Events
  module Db
    class CompetitionRecord < ActiveRecord::Base
      self.table_name = 'competitions'
    end
  end
end
