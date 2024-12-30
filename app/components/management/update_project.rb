module Management
  class UpdateProject

    def initialize(form)
      @form = form
    end

    def call(id:, raw_inputs:)
      form_outputs = form.call(raw_inputs.to_unsafe_h)
      return Failure(errors: form_outputs.messages.values) unless form_outputs.success?
      return Failure(:not_found) unless Management::ProjectRecord.exists?(id: id)

      project = Management::ProjectRecord.find(id)
      project.update(form_outputs.to_h)

      Success(project: project)
    end

    private

    attr_reader :form
  end
end
