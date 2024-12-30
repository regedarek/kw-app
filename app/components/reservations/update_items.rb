module Reservations
  class UpdateItems
    def initialize(form)
      @form = form
    end

    def call(raw_inputs:)
      form_outputs = form.call(raw_inputs)

      return Failure(form_outputs.messages(full: true)) unless form_outputs.success?

      reservation = Db::Reservation.find(form_outputs[:id])
      items_ids = form_outputs[:items_ids].split(' ')
      items = Db::Item.where(rentable_id: items_ids)

      return Failure(items: 'Rezerwacja musi mieć jakieś przedmioty!') unless items.any?

      reservation.items = items
      reservation.save

      Success(:success)
    end

    private

    attr_reader :form
  end
end
