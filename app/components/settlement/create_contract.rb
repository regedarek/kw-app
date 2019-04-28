module Settlement
  class CreateContract
    include Dry::Monads::Either::Mixin

    def initialize(repository, form)
      @repository = repository
      @form = form
    end

    def call(raw_inputs:, creator_id:)
      form_outputs = form.call(raw_inputs.to_unsafe_h)
      return Left(form_outputs.messages(full: true)) unless form_outputs.success?

      contract = repository.create_contract(form_outputs: form_outputs, creator_id: creator_id)

      office_king_ids = Db::User.where(":name = ANY(roles)", name: "office_king").map(&:id)
      contract_user_ids = contract.users.map(&:id)
      recepient_ids = (office_king_ids + contract_user_ids).uniq.reject{|id| id == creator_id }
      recepient_ids.each do |id|
        NotificationCenter::NotificationRecord.create(
          recipient_id: id,
          actor_id: contract.creator_id,
          action: 'created_contract',
          notifiable_id: contract.id,
          notifiable_type: 'Settlement::ContractRecord'
        )
      end
      ContractMailer.notify(contract).deliver_later
      return Right(contract)
    end

    private

    attr_reader :repository, :form
  end
end
