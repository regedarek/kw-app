module Events
  module Competitions
    module Workers
      class DestroyExpiredEventSignUpWorker
        include Sidekiq::Worker

        def perform(sign_up_id)
          ::Events::Competitions::SignUps::Destroy.new(
            Events::Competitions::Repository.new
          ).call(id: sign_up_id)
        end
      end
    end
  end
end
