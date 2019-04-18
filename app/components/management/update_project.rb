module Management
  class UpdateProject
    include Dry::Monads::Either::Mixin

    def initialize(form)
      @form = form
    end

    def call(id:, raw_inputs:)
      form_outputs = form.call(raw_inputs.to_unsafe_h)
      return Left(errors: form_outputs.messages.values) unless form_outputs.success?
      return Left(:not_found) unless Management::ProjectRecord.exists?(id: id)

      project = Management::ProjectRecord.find(id)
      project.update(form_outputs.to_h)

      Right(project: project)
    end

    private

    attr_reader :form
  end
end
