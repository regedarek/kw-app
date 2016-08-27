require 'rails_helper'

describe Payments::InitializeDotPay do
  let! (:registration) { Factories::Registration.create! }

  describe '#call' do
    it 'updates registration payment with dot_pay_id' do
      result = described_class.new(registration_id: registration.id).create
      expect(result.success?).to eq(true)
    end
  end
end
