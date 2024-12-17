module Membership
  class FeesMailer < ApplicationMailer
    append_view_path 'app/components/'

    def yearly_reminder(emails)
      mail(
        bcc: emails,
        from: 'biuro@kw.krakow.pl',
        subject: "Przypomnienie opłacenia składki członkowskiej KW Kraków za rok #{Date.today.year}"
      )
    end
  end
end
