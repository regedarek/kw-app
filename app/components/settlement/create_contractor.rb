module Settlement
  class CreateContractor
    def initialize(repository, form)
      @repository = repository
      @form = form
    end

    def call(raw_inputs:)
      form_outputs = form.call(raw_inputs.to_unsafe_h)
      return Failure(form_outputs.messages(full: true)) unless form_outputs.success?

      contract = repository.create_contractor(form_outputs: form_outputs)

      Success(contract)
    end

    private

    attr_reader :repository, :form
  end
end
