module Charity
  class CreateDonation
    include Dry::Monads::Either::Mixin

    def initialize(repository, form)
      @repository = repository
      @form = form
    end

    def call(raw_inputs:)
      form_outputs = form.call(raw_inputs.to_unsafe_h)
      return Left(message: 'Kwota i imie i nazwisko musi być uzupełnione!') unless form_outputs.success?

      donation = repository.create_donation(form_outputs: form_outputs)
      donation.update description: "Darowizna książki Karola Życzkowskiego dla #{donation.display_name}"
      payment = donation.payment
      Right(payment: payment)
    end

    private

    attr_reader :repository, :form
  end
end
