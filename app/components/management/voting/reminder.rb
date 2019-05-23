module Management
  module Voting
    class Reminder
      def self.send_reminders
        Management::Voting::CaseRecord.where(state: 'voting').each do |case_record|
          Management::Voting::Repository.new.missing_votes_on(case_record.id).each do |user|
            if case_record.created_at <= 3.days.ago
              Management::Voting::Mailer.notify(case_record.id, user.id).deliver_later
            end
          end
        end

        Net::HTTP.get(URI('https://hc-ping.com/ac21c930-dade-460f-a71f-516b5dbf9ee5'))
      end

      def self.close_outdated
        Management::Voting::CaseRecord.where(state: 'voting').each do |case_record|
          if case_record.created_at <= 7.days.ago
            case_record.finish!
          end
        end

        Net::HTTP.get(URI('https://hc-ping.com/17d004da-8867-456d-b304-bb6b9f741e81'))
      end
    end
  end
end
