module Training
  module Questionare
    class SnwProfilesController < ApplicationController
      include EitherMatcher
      append_view_path 'app/components'

      def new

      end

      def create
        either(create_snw_profile) do |result|
          result.success do
            redirect_to root_path, flash: { notice: 'Created' }
          end

          result.failure do |errors|
            flash[:error] = errors.values.join(", ")
            render(action: :new)
          end
        end
      end

      private

      def create_snw_profile
        Training::Questionare::SnwProfileService.new(
          Training::Questionare::SnwProfileRepository.new,
          Training::Questionare::SnwProfileForm.new
        ).create(raw_inputs: snw_profile_params)
      end

      def snw_profile_params
        params.require(:snw_profile).permit(:question_1, :question_2)
      end
    end
  end
end
