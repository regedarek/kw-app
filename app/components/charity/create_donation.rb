require 'result'
require 'failure'
require 'success'

module Charity
  class CreateDonation
    def initialize(repository, form)
      @repository = repository
      @form = form
    end

    def call(raw_inputs:)
      # Convert ActionController::Parameters to hash if needed
      inputs = raw_inputs.respond_to?(:to_unsafe_h) ? raw_inputs.to_unsafe_h : raw_inputs
      form_outputs = form.call(inputs)
      
      # Check for terms_of_service validation error
      return Failure(:invalid, message: 'Zaakceptuj regulamin darowizn') if form_outputs.errors.to_h.key?(:terms_of_service)
      return Failure(:invalid, message: 'Kwota i cel dotacji musi być uzupełnione!') unless form_outputs.success?

      donation = repository.create_donation(form_outputs: form_outputs)

      if donation.ski_service?
        donation.update description: "Darowizna na rzecz Klubu Wysokogórskiego Kraków - Sprzęt serwisowy od #{donation.display_name}"
      end

      if donation.michal?
        donation.update description: "Darowizna na tablicę upamiętniającą Michała Wojarskiego od #{donation.display_name}"
      end

      payment = donation.payment
      Success(payment: payment)
    end

    private

    attr_reader :repository, :form
  end
end
