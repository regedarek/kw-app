module Charity
  class CreateDonation
    include Dry::Monads::Either::Mixin

    def initialize(repository, form)
      @repository = repository
      @form = form
    end

    def call(raw_inputs:)
      form_outputs = form.call(raw_inputs)
      return Left(form_outputs.messages(full: true)) unless form_outputs.success?

      donation = repository.create_donation(form_outputs: form_outputs)
      payment = donation.payment
      Right(payment: payment)
    end

    private

    attr_reader :repository, :form
  end
end
