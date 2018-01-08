module Events
  module Competitions
    class Repository
      def find_sign_up(id)
        Events::Db::SignUpRecord.find_by(id: id)
      end

      def create(form_outputs:)
        record = Events::Db::CompetitionRecord.create!(form_outputs.to_h)
        Events::Competition.from_record(record)
      end

      def create_sign_up(competition_id:, form_outputs:)
        attributes = form_outputs
          .to_h.merge(competition_record_id: competition_id)
        record = Events::Db::SignUpRecord.create!(attributes)
        record.create_payment(dotpay_id: SecureRandom.hex(13))


        Events::SignUp.from_record(record)
      end
    end
  end
end
