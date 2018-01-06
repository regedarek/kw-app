module Events
  module Repositories
    class Competitions
      def create(form_outputs:)
        record = Events::Db::CompetitionRecord.create!(form_outputs.to_h)
        Events::Competition.from_record(record)
      end
    end
  end
end
