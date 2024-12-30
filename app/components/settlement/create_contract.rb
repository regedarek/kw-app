module Settlement
  class CreateContract
    def initialize(repository, form)
      @repository = repository
      @form = form
    end

    def call(raw_inputs:, creator_id:)
      form_outputs = form.call(raw_inputs.to_unsafe_h)
      return Failure(form_outputs.messages(locale: :pl)) unless form_outputs.success?

      contract = repository.create_contract(form_outputs: form_outputs, creator_id: creator_id)

      office_king_ids = Db::User.where(":name = ANY(roles)", name: "office_king").map(&:id)
      financial_ids = Db::User.where(":name = ANY(roles)", name: "financial_management").map(&:id)
      responsible_ids = Db::User.where(":name = ANY(roles)", name: contract.group_type).map(&:id)
      contract_user_ids = contract.users.map(&:id)
      recepient_ids = (responsible_ids + office_king_ids + financial_ids + contract_user_ids).compact.uniq.reject{|id| id == creator_id }
      recepient_ids.each do |recipient_id|
        NotificationCenter::NotificationRecord.create(
          recipient_id: recipient_id,
          actor_id: contract.creator_id,
          action: 'created_contract',
          notifiable_id: contract.id,
          notifiable_type: 'Settlement::ContractRecord'
        ) if contract && recipient_id && contract&.creator_id
      end

      ::Settlement::ContractMailer.notify(contract).deliver_later
      return Success(contract)
    end

    private

    attr_reader :repository, :form
  end
end
