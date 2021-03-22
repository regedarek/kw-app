module NotificationCenter
  module Mailers
    class CommentsMailer < ApplicationMailer
      include Rails.application.routes.url_helpers
      append_view_path 'app/components/'

      def notify(comment)
        @comment = comment
        to_emails = [comment.commentable.colleagues, comment.commentable.comments.map(&:user)].flatten.uniq.map(&:email) - [comment.user.email]

        mail(
          to: to_emails,
          from: 'no-reply@kw.krakow.pl',
          subject: "Panel KW Kraków - Nowy komentarz dotyczący twojego przejścia: #{comment.commentable.name}"
        ) if to_emails.any?
      end
    end
  end
end
