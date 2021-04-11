module Training
  module Supplementary
    module Workers
      class DestroyExpiredSignUpWorker
        include Sidekiq::Worker

        def perform(sign_up_id)
          sign_up = Training::Supplementary::Repository.new.find_sign_up(sign_up_id)
          course_id = sign_up.course_id

          Training::Supplementary::DestroySignUp.new(
            Training::Supplementary::Repository.new
          ).call(id: sign_up_id) if sign_up
        end
      end
    end
  end
end
