module Management
  module Voting
    class Mailer < ApplicationMailer
      def notify(case_id, user_id)
        @case = Management::Voting::CaseRecord.find(case_id)
        @user = Db::User.find(user_id)

        mail(
          to: @user.email,
          from: 'kw@kw.krakow.pl',
          subject: "Nowe głosowanie: #{@case.name} ##{@case.id}",
          reply_to: Management::Voting::Repository.new.management_users.map(&:email)
        )
      end
    end
  end
end
