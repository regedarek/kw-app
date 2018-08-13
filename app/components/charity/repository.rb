module Charity
  class Repository
    def create_donation(form_outputs:)
      donation = Charity::DonationRecord.create!(form_outputs.to_h)
      donation.create_payment(dotpay_id: SecureRandom.hex(13))
      donation
    end
  end
end
