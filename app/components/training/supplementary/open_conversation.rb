module Training
  module Supplementary
    class OpenConversation
      include Dry::Monads::Either::Mixin

      def initialize(repository)
        @repository = repository
      end

      def call(course_id:)
        return Left(:no_course) unless Training::Supplementary::CourseRecord.exists?(id: course_id)
        course = Training::Supplementary::CourseRecord.find(course_id)
        return Left(:already_exists) if course.conversation_at
        return Left(:no_participants) unless repository.users_signed_in(course_id).any?

        receipt = course.organizer.send_message(
          repository.users_signed_in(course_id),
          "Tutaj możecie kontaktować się w sprawie dojazdu, po wydarzeniu z instruktorem, koordynatorem. Konwersacja jest widoczna tylko dla uczestników",
          "[#{course.start_date.to_date}] #{course.name}"
        )
        course.conversations << receipt.conversation
        course.update(conversation_at: Time.current)

        Right(:success)
      end

      private

      attr_reader :repository
    end
  end
end
