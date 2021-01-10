module Events
  module Competitions
    module Workers
      class DestroySignUpsEnqueuer
        include Sidekiq::Worker

        def perform(**)
          expired_sign_ups = Events::Competitions::Repository.new.expired_sign_ups
          expired_sign_ups.each do |sign_up|
            Events::Competitions::Worker::DestroyExpiredSignUpWorker.perform_async(sign_up.id)
          end
        end
      end
    end
  end
end
