module Settlement
  class UpdateContract
    include Dry::Monads::Either::Mixin

    def initialize(repository, form)
      @repository = repository
      @form = form
    end

    def call(id:, raw_inputs:)
      form_outputs = form.call(raw_inputs.to_unsafe_h)
      return Left(form_outputs.messages(locale: I18n.locale)) unless form_outputs.success?

      contract = Settlement::ContractRecord.find(id)
      contract.update(form_outputs.to_h)

      Right(contract)
    end

    private

    attr_reader :repository, :form
  end
end
