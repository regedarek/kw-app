module Management
  module Voting
    class Mailer < ApplicationMailer
      def notify_commission(commission_id)
        @commission = Management::Voting::CommissionRecord.find(commission_id)
        @setting = Management::SettingsRecord.find_by(path: '/pelnomocnictwo/potwierdzenie')

        mail(
          to: [@commission.owner.email, @commission.authorized.email, 'pelnomocnictwa@kw.krakow.pl'],
          from: 'pelnomocnictwa@kw.krakow.pl',
          subject: "Udzielono pełnomocnictwa #{@commission.authorized.display_name} na Walne Zebranie Członków",
          reply_to: 'pelnomocnictwa@kw.krakow.pl'
        )
      end

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
