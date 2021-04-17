module Training
  module Supplementary
    module Workers
      class OpenConversationWorker
        include Sidekiq::Worker

        def perform(course_id)
          Training::Supplementary::OpenConversation.new(
            Training::Supplementary::Repository.new
          ).call(course_id: course_id)

          Training::Supplementary::AddToConversation.new(
            Training::Supplementary::Repository.new
          ).call(course_id: course_id)
        end
      end
    end
  end
end
