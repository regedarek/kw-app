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
    end
  end
end
