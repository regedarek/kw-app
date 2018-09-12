module Training
  module Supplementary
    class CreateSignUp
      include Dry::Monads::Either::Mixin

      def initialize(repository, form)
        @repository = repository
        @form = form
      end

      def call(raw_inputs:)
        form_outputs = form.call(raw_inputs)
        return Left(form_outputs.messages(full: true)) unless form_outputs.success?

        course = Training::Supplementary::CourseRecord.find(form_outputs[:course_id])
        if form_outputs[:user_id].present?
          user = ::Db::User.find(form_outputs[:user_id])
          fee = ::Db::Membership::Fee.find_by(kw_id: user.kw_id, year: Date.today.year)

          if course.last_fee_paid
            if fee.present?
              return Left(fee: I18n.t('.not_last_fee')) if !fee.payment.paid?
            else
              return Left(fee: I18n.t('.not_last_fee'))
            end
          end
        end
        return Left(email: I18n.t('.email_not_unique')) if Training::Supplementary::SignUpRecord.exists?(course_id: form_outputs[:course_id], email: form_outputs[:email])
        sign_up = repository.sign_up!(
          course_id: form_outputs[:course_id],
          email: form_outputs[:email],
          user_id: form_outputs[:user_id]
        )
        sign_up.update(supplementary_course_package_type_id: form_outputs[:supplementary_course_package_type_id]) if course.packages
        if Training::Supplementary::Limiter.new(course).in_limit?(sign_up)
          Training::Supplementary::SignUpMailer.sign_up(sign_up.id).deliver_later
        end
        Right(:success)
      end

      private

      attr_reader :repository, :form
    end
  end
end
