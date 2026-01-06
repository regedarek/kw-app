require 'rails_helper'

RSpec.describe Charity::DonationsController, type: :controller do
  let!(:user) { Factories::User.create! }

  before do
    sign_in user
  end

  describe 'GET #new' do
    it 'returns a successful response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          donation: {
            cost: '100',
            action_type: 'michal',
            display_name: 'Test Donor',
            terms_of_service: '1'
          }
        }
      end

      it 'creates a new donation' do
        expect {
          post :create, params: valid_params
        }.to change(Charity::DonationRecord, :count).by(1)
      end

      it 'creates a payment for the donation' do
        expect {
          post :create, params: valid_params
        }.to change(Db::Payment, :count).by(1)
      end

      it 'redirects to charge payment path' do
        post :create, params: valid_params
        payment = Db::Payment.last
        expect(response).to redirect_to(charge_payment_path(payment.id))
      end

      it 'sets description for michal action_type' do
        post :create, params: valid_params
        donation = Charity::DonationRecord.last
        expect(donation.description).to eq('Darowizna na tablicę upamiętniającą Michała Wojarskiego od Test Donor')
      end

      it 'sets description for ski_service action_type' do
        post :create, params: valid_params.deep_merge(donation: { action_type: 'ski_service' })
        donation = Charity::DonationRecord.last
        expect(donation.description).to eq('Darowizna na rzecz Klubu Wysokogórskiego Kraków - Sprzęt serwisowy od Test Donor')
      end
    end

    context 'with invalid parameters - terms not accepted' do
      let(:invalid_params) do
        {
          donation: {
            cost: '100',
            action_type: 'michal',
            display_name: 'Test Donor',
            terms_of_service: '0'
          }
        }
      end

      it 'does not create a donation' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Charity::DonationRecord, :count)
      end

      it 'redirects to michal_path' do
        post :create, params: invalid_params
        expect(response).to redirect_to(michal_path)
      end

      it 'sets error flash message' do
        post :create, params: invalid_params
        expect(flash[:error]).to eq('Zaakceptuj regulamin darowizn')
      end
    end

    context 'with invalid parameters - missing required fields' do
      let(:invalid_params) do
        {
          donation: {
            cost: '',
            action_type: '',
            display_name: '',
            terms_of_service: '1'
          }
        }
      end

      it 'does not create a donation' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Charity::DonationRecord, :count)
      end

      it 'redirects to michal_path' do
        post :create, params: invalid_params
        expect(response).to redirect_to(michal_path)
      end

      it 'sets error flash message' do
        post :create, params: invalid_params
        expect(flash[:error]).to eq('Kwota i cel dotacji musi być uzupełnione!')
      end
    end

    context 'with missing cost' do
      let(:invalid_params) do
        {
          donation: {
            cost: '',
            action_type: 'michal',
            display_name: 'Test Donor',
            terms_of_service: '1'
          }
        }
      end

      it 'does not create a donation' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Charity::DonationRecord, :count)
      end

      it 'sets appropriate error message' do
        post :create, params: invalid_params
        expect(flash[:error]).to eq('Kwota i cel dotacji musi być uzupełnione!')
      end
    end

    context 'with missing action_type' do
      let(:invalid_params) do
        {
          donation: {
            cost: '100',
            action_type: '',
            display_name: 'Test Donor',
            terms_of_service: '1'
          }
        }
      end

      it 'does not create a donation' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Charity::DonationRecord, :count)
      end
    end

    context 'with missing display_name' do
      let(:invalid_params) do
        {
          donation: {
            cost: '100',
            action_type: 'michal',
            display_name: '',
            terms_of_service: '1'
          }
        }
      end

      it 'does not create a donation' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Charity::DonationRecord, :count)
      end
    end
  end
end