module Settlement
  class ContractMailer < ApplicationMailer
    def notify(contract)
      @contract = contract

      mail(
        to: @contract.users.map(&:email),
        cc: @contract.users.map(&:email),
        from: 'kw@kw.krakow.pl',
        subject: "Nowe rozliczenie: #{@contract.title}"
      )
    end
  end
end
