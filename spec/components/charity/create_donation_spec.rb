require 'rails_helper'
require 'result'
require 'failure'
require 'success'

RSpec.describe Charity::CreateDonation do
  let(:repository) { Charity::Repository.new }
  let(:form) { Charity::DonationForm.new }
  let(:service) { described_class.new(repository, form) }
  let!(:user) { Factories::User.create! }

  describe '#call' do
    context 'when form validation fails' do
      it 'returns Failure when terms_of_service is not accepted' do
        raw_inputs = {
          cost: '100',
          action_type: 'michal',
          display_name: 'John Doe',
          terms_of_service: '0'
        }

        result = service.call(raw_inputs: raw_inputs)

        expect(result).to be_failure
        result.invalid do |message:|
          expect(message).to eq('Zaakceptuj regulamin darowizn')
        end
      end

      it 'returns Failure when required fields are missing' do
        raw_inputs = {
          cost: '',
          action_type: '',
          display_name: '',
          terms_of_service: '1'
        }

        result = service.call(raw_inputs: raw_inputs)

        expect(result).to be_failure
        result.invalid do |message:|
          expect(message).to eq('Kwota i cel dotacji musi być uzupełnione!')
        end
      end

      it 'returns Failure when cost is missing' do
        raw_inputs = {
          cost: '',
          action_type: 'michal',
          display_name: 'John Doe',
          terms_of_service: '1'
        }

        result = service.call(raw_inputs: raw_inputs)

        expect(result).to be_failure
        result.invalid do |message:|
          expect(message).to eq('Kwota i cel dotacji musi być uzupełnione!')
        end
      end

      it 'returns Failure when action_type is missing' do
        raw_inputs = {
          cost: '100',
          action_type: '',
          display_name: 'John Doe',
          terms_of_service: '1'
        }

        result = service.call(raw_inputs: raw_inputs)

        expect(result).to be_failure
        result.invalid do |message:|
          expect(message).to eq('Kwota i cel dotacji musi być uzupełnione!')
        end
      end

      it 'returns Failure when display_name is missing' do
        raw_inputs = {
          cost: '100',
          action_type: 'michal',
          display_name: '',
          terms_of_service: '1'
        }

        result = service.call(raw_inputs: raw_inputs)

        expect(result).to be_failure
        result.invalid do |message:|
          expect(message).to eq('Kwota i cel dotacji musi być uzupełnione!')
        end
      end
    end

    context 'when form validation passes' do
      it 'creates donation with michal action_type and returns payment' do
        raw_inputs = {
          cost: '77',
          action_type: 'michal',
          display_name: 'Dariusz Finster',
          terms_of_service: '1'
        }

        result = service.call(raw_inputs: raw_inputs)

        expect(result).to be_success
        
        result.success do |payment:|
          expect(payment).to be_present
          expect(payment).to be_a(Db::Payment)
          expect(payment.dotpay_id).to be_present
          
          donation = payment.payable
          expect(donation).to be_a(Charity::DonationRecord)
          expect(donation.cost).to eq(77)
          expect(donation.action_type).to eq('michal')
          expect(donation.display_name).to eq('Dariusz Finster')
          expect(donation.description).to eq('Darowizna na tablicę upamiętniającą Michała Wojarskiego od Dariusz Finster')
        end
      end

      it 'creates donation with ski_service action_type and returns payment' do
        raw_inputs = {
          cost: '150',
          action_type: 'ski_service',
          display_name: 'Jane Smith',
          terms_of_service: '1'
        }

        result = service.call(raw_inputs: raw_inputs)

        expect(result).to be_success
        
        result.success do |payment:|
          expect(payment).to be_present
          expect(payment).to be_a(Db::Payment)
          
          donation = payment.payable
          expect(donation).to be_a(Charity::DonationRecord)
          expect(donation.cost).to eq(150)
          expect(donation.action_type).to eq('ski_service')
          expect(donation.display_name).to eq('Jane Smith')
          expect(donation.description).to eq('Darowizna na rzecz Klubu Wysokogórskiego Kraków - Sprzęt serwisowy od Jane Smith')
        end
      end

      it 'creates donation with optional user_id' do
        raw_inputs = {
          cost: '200',
          action_type: 'michal',
          display_name: 'Member Donor',
          user_id: user.id,
          terms_of_service: '1'
        }

        result = service.call(raw_inputs: raw_inputs)

        expect(result).to be_success
        
        result.success do |payment:|
          donation = payment.payable
          expect(donation.user_id).to eq(user.id)
          expect(donation.user).to eq(user)
        end
      end

      it 'generates unique dotpay_id for each donation' do
        raw_inputs = {
          cost: '50',
          action_type: 'michal',
          display_name: 'Test Donor',
          terms_of_service: '1'
        }

        result1 = service.call(raw_inputs: raw_inputs)
        result2 = service.call(raw_inputs: raw_inputs)

        dotpay_id_1 = nil
        dotpay_id_2 = nil

        result1.success { |payment:| dotpay_id_1 = payment.dotpay_id }
        result2.success { |payment:| dotpay_id_2 = payment.dotpay_id }

        expect(dotpay_id_1).to be_present
        expect(dotpay_id_2).to be_present
        expect(dotpay_id_1).not_to eq(dotpay_id_2)
      end
    end
  end
end