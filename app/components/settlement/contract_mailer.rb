module Settlement
  class ContractMailer < ApplicationMailer
    def notify(contract)
      @contract = contract
      @office_kings = Db::User.where(":name = ANY(roles)", name: "office_king")
      @acceptors = Db::User.where(":name = ANY(roles)", name: "financial_management")

      mail(
        to: ([@contract.creator.email] + @contract.users.map(&:email)).uniq,
        from: 'rozliczenia@kw.krakow.pl',
        subject: "Nowe rozliczenie: #{@contract.title} ##{contract.internal_number}/#{contract.period_date.year}"
      )
    end

    def state_changed(contract)
      @contract = contract
      @office_kings = Db::User.where(":name = ANY(roles)", name: "office_king")
      @acceptors = Db::User.where(":name = ANY(roles)", name: "financial_management")

      mail(
        to: ([@contract.creator.email] + @contract.users.map(&:email)).uniq,
        from: 'rozliczenia@kw.krakow.pl',
        subject: "Rozliczenie: #{@contract.title} ##{contract.internal_number}/#{contract.period_date.year} zmieniło status na #{I18n.t(@contract.state, scope: 'activerecord.attributes.settlement/contract_record.states')}"
      )
    end
  end
end
