module Training
  module Supplementary
    class FillEmptyPlaces
      include Dry::Monads::Either::Mixin

      def initialize(repository)
        @repository = repository
      end

      def call(course_id:)
        repository.sign_ups_on_hold(course_id).each do |sign_up|
          if Training::Supplementary::Limiter.new(sign_up.course).in_limit?(sign_up)
            return Left(payment: I18n.t('.not_found')) unless sign_up.payment.present?
            Training::Supplementary::SendEmailWithPayment.new(repository).call(id: sign_up.id)
          end
        end

        Right(:success)
      end

      private

      attr_reader :repository
    end
  end
end
