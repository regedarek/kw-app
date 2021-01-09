module Training
  module Supplementary
    module Workers
      class DestroyExpiredSignUpWorker
        include Sidekiq::Worker

        def perform(sign_up_id)
          Training::Supplementary::DestroySignUp.new(
            Training::Supplementary::Repository.new
          ).call(id: sign_up_id)
        end
      end
    end
  end
end

