module Settlement
  class ContractMailer < ApplicationMailer
    def notify(contract)
      @contract = contract
      @office_kings = Db::User.where(":name = ANY(roles)", name: "office_king")
      @acceptors = Db::User.where(":name = ANY(roles)", name: "financial_management")

      mail(
        to: ([@contract.creator.email] + @contract.users.map(&:email) + @acceptors.map(&:email) + @office_kings.map(&:email)).uniq,
        from: 'kw@kw.krakow.pl',
        subject: "Nowe rozliczenie: #{@contract.title} ##{@contract.number}"
      )
    end
  end
end
