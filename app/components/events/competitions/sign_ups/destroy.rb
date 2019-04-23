module Events
  module Competitions
    module SignUps
      class Destroy
        include Dry::Monads::Either::Mixin

        def initialize(repository)
          @repository = repository
        end

        def call(id:)
          sign_up = repository.find_sign_up(id)
          return Left(email: I18n.t('.not_found')) unless sign_up.present?
          return Left(payment: I18n.t('.not_found')) unless sign_up.payment.present?
          Payments::DeletePayment.new(payment: sign_up.payment).delete if sign_up.payment.payment_url

          sign_up.destroy
          Right(:success)
        end

        private

        attr_reader :repository
      end
    end
  end
end
