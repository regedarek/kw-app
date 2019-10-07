module Management
  module Snw
    class Mailer < ApplicationMailer
      def apply(apply_id)
        @apply = Management::Snw::SnwApplyRecord.find(apply_id)
        @profile = Db::Profile.find_by(kw_id: @apply.kw_id)

        mail(
          to: [@profile.email, 'zgloszenia.snw@kw.krakow.pl'],
          from: 'zgloszenia.snw@kw.krakow.pl',
          subject: "Zgłoszenie do SNW: #{@profile.display_name} - ##{@apply.kw_id}",
          reply_to: 'zgloszenia.snw@kw.krakow.pl'
        )
      end
    end
  end
end
