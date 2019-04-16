module Settlement
  class ContractMailer < ApplicationMailer
    def notify(contract)
      @contract = contract
      @office_kings = Db::User.where(":name = ANY(roles)", name: "office_king")

      mail(
        to: (@contract.users.map(&:email) + @office_kings.map(&:email)).uniq,
        from: 'kw@kw.krakow.pl',
        subject: "Nowe rozliczenie: #{@contract.title} ##{@contract.id}"
      )
    end
  end
end
