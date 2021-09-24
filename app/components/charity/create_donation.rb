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
      if donation.crack?
        donation.update description: "Darowizna na rzecz Klubu Wysokogórskiego Kraków - Rysa od #{donation.display_name}"
      end

      if donation.mariusz?
        donation.update description: "Darowizna na pomoc społeczną rodziny Mariusza Norweckiego od #{donation.display_name}"
      end

      payment = donation.payment
      Right(payment: payment)
    end

    private

    attr_reader :repository, :form
  end
end
