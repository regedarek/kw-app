require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do
  let(:user) { double('User', id: 1, admin?: false, roles: []) }
  let(:payment) { double('Payment', id: 1, payment_url: nil, payable: nil) }

  before do
    allow(controller).to receive(:user_signed_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
    allow(Db::Payment).to receive(:find).with(payment.id.to_s).and_return(payment)
    allow(payment).to receive(:is_a?).with(Events::Db::SignUpRecord).and_return(false)
    allow(payment).to receive(:is_a?).with(Training::Supplementary::SignUpRecord).and_return(false)
  end

  describe 'POST #charge' do
    let(:create_payment_service) { instance_double(Payments::CreatePayment) }

    before do
      allow(Payments::CreatePayment).to receive(:new).with(payment: payment).and_return(create_payment_service)
    end

    context 'when payment is successful' do
      let(:payment_url) { 'https://ssl.dotpay.pl/test_payment/?pid=test123' }

      before do
        allow(create_payment_service).to receive(:create).and_return(
          Success.new(payment_url: payment_url)
        )
        allow(payment).to receive(:update)
      end

      it 'redirects to payment URL' do
        post :charge, params: { id: payment.id }
        
        expect(response).to redirect_to(payment_url)
      end

      it 'updates payment with payment_url' do
        expect(payment).to receive(:update).with(payment_url: payment_url)
        
        post :charge, params: { id: payment.id }
      end
    end

    context 'when payment URL is wrong' do
      let(:error_message) { 'Błędny link płatności, skonktaktuj się z administratorem.' }

      before do
        allow(create_payment_service).to receive(:create).and_return(
          Failure.new(:wrong_payment_url, { message: error_message })
        )
      end

      it 'redirects to root path with alert' do
        post :charge, params: { id: payment.id }
        
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(error_message)
      end
    end

    context 'when dotpay request fails' do
      let(:error_message) { 'Błąd podczas generowania linka płatności skontaktuj sie z administratorem.' }

      before do
        allow(create_payment_service).to receive(:create).and_return(
          Failure.new(:dotpay_request_error, { message: error_message })
        )
      end

      it 'redirects to root path with alert' do
        post :charge, params: { id: payment.id }
        
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(error_message)
      end

      it 'does not raise ArgumentError for unknown keyword' do
        expect {
          post :charge, params: { id: payment.id }
        }.not_to raise_error
      end
    end

    context 'when dotpay request fails with body keyword (demonstrating the bug was fixed)' do
      let(:error_message) { 'Błąd podczas generowania linka płatności skontaktuj sie z administratorem.' }

      before do
        # If we were still passing body: as a keyword argument, this would raise:
        # ArgumentError: unknown keyword: :body
        # Because the controller block only accepts |message:| not |message:, body:|
        # After our fix, we only pass message: so it works
        allow(create_payment_service).to receive(:create).and_return(
          Failure.new(:dotpay_request_error, { message: error_message })
        )
      end

      it 'handles the error without raising ArgumentError' do
        expect {
          post :charge, params: { id: payment.id }
        }.not_to raise_error
        
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(error_message)
      end
    end

    context 'when payment service would have returned body in the failure (before fix)' do
      # This test demonstrates what WOULD happen if someone accidentally
      # passed extra keyword arguments that the controller block doesn't accept
      let(:error_message) { 'Błąd podczas generowania linka płatności skontaktuj sie z administratorem.' }
      let(:extra_data) { { error: 'some error' } }

      it 'raises ArgumentError if extra keywords are passed' do
        # Simulating the OLD buggy behavior where body: was included
        allow(create_payment_service).to receive(:create).and_return(
          Failure.new(:dotpay_request_error, { message: error_message, body: extra_data })
        )

        expect {
          post :charge, params: { id: payment.id }
        }.to raise_error(ArgumentError, /unknown keyword.*:body/)
      end
    end
  end
end