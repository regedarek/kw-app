module Settlement
  class CreateContract
    include Dry::Monads::Either::Mixin

    def initialize(repository, form)
      @repository = repository
      @form = form
    end

    def call(raw_inputs:, creator_id:)
      form_outputs = form.call(raw_inputs.to_unsafe_h)
      byebug
      return Left(form_outputs.messages(full: true)) unless form_outputs.success?

      contract = repository.create_contract(form_outputs: form_outputs, creator_id: creator_id)
      ContractMailer.notify(contract).deliver_later
      return Right(contract)
    end

    private

    attr_reader :repository, :form
  end
end
