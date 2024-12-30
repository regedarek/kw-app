module Training
  module Activities
    class CreateSkiRoute

      def initialize(repository, form)
        @repository = repository
        @form = form
      end

      def call(raw_inputs:, user_id:)
        form_outputs = form.call(raw_inputs)
        return Failure(form_outputs.messages(locale: :pl)) unless form_outputs.success?

        route = repository.create(form_outputs: form_outputs, user_id: user_id)

        form_outputs[:colleague_ids].delete(user_id.to_s)
        form_outputs[:colleague_ids].reject(&:blank?).each do |id|
          NotificationCenter::NotificationRecord.create(
            recipient_id: id,
            actor_id: user_id,
            action: 'assigned_to_route',
            notifiable_id: route.id,
            notifiable_type: 'Db::Activities::MountainRoute'
          )
        end if route && user_id
        Success(:success)
      end

      private

      attr_reader :repository, :form
    end
  end
end
