module Events
  module Admin
    module Competitions
      class Update

        def initialize(competitions_repository, create_competition_form)
          @competitions_repository = competitions_repository
          @create_competition_form = create_competition_form
        end

        def call(id:, raw_inputs:)
          form_outputs = create_competition_form.call(raw_inputs)
          return Failure(form_outputs.messages(full: true)) unless form_outputs.success?

          competitions_repository.update(id: id, form_outputs: form_outputs)
          Success(:success)
        end

        private

        attr_reader :competitions_repository, :create_competition_form
      end
    end
  end
end
