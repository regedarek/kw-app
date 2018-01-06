module Events
  module Competitions
    class Repository
      def create(form_outputs:)
        record = Events::Db::CompetitionRecord.create!(form_outputs.to_h)
        Events::Competition.from_record(record)
      end

      def create_sign_up(competition_id:, form_outputs:)
        attributes = form_outputs
          .to_h.merge(competition_record_id: competition_id)
        record = Events::Db::SignUpRecord.create!(attributes)

        Events::SignUp.from_record(record)
      end
    end
  end
end
