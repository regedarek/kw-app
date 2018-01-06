module Events
  module Repositories
    class Competitions
      def create(form:)
        record = Events::Db::CompetitionRecord.create!(form.to_h)
        Events::Competition.from_record(record)
      end
    end
  end
end
