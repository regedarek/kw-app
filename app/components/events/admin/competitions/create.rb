module Events
  module Admin
    module Competitions
      class Create
        include Dry::Monads::Either::Mixin

        def initialize(competitions_repository, create_competition_form)
          @competitions_repository = competitions_repository
          @create_competition_form = create_competition_form
        end

        def call(raw_inputs:)
          form_outputs = create_competition_form.call(raw_inputs)
          return Left(form_outputs.messages(full: true)) unless form_outputs.success?

          competitions_repository.create(form_outputs: form_outputs)
          Right(:success)
        end

        private

        attr_reader :competitions_repository, :create_competition_form
      end
    end
  end
end
