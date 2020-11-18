module Management
  module Voting
    class CreateCommission
      include Dry::Monads::Either::Mixin

      def initialize(form)
        @form = form
      end

      def call(raw_inputs:)
        commission_record = Management::Voting::CommissionRecord.new(raw_inputs)

        if commission_record.save
          Management::Voting::Mailer.notify_commission(commission_record.id).deliver_later

          Right(commission_record)
        else
          Left(commission_record.errors.full_messages)
        end
      end

      private

      attr_reader :form
    end
  end
end
