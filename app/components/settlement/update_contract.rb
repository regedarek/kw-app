module Settlement
  class UpdateContract
    include Dry::Monads::Either::Mixin

    def initialize(repository, form)
      @repository = repository
      @form = form
    end

    def call(id:, raw_inputs:)
      form_outputs = form.call(raw_inputs.to_unsafe_h)
      return Left(form_outputs.messages(locale: I18n.locale)) unless form_outputs.success?

      contract = Settlement::ContractRecord.find(id)
      contract.update(form_outputs.to_h)

      office_king_ids = Db::User.where(":name = ANY(roles)", name: "office_king").map(&:id)
      contract_user_ids = contract.users.map(&:id)
      recepient_ids = (office_king_ids + contract_user_ids).uniq.reject{|id| id == contract.creator_id }
      recepient_ids.each do |id|
        NotificationCenter::NotificationRecord.create(
          recipient_id: id,
          actor_id: contract.creator_id,
          action: 'updated_contract',
          notifiable_id: contract.id,
          notifiable_type: 'Settlement::ContractRecord'
        )
      end

      Right(contract)
    end

    private

    attr_reader :repository, :form
  end
end
