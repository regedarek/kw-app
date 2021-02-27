module Business
  class PaymentsController < ApplicationController
    include EitherMatcher

    def charge
      authorize! :create, Business::CourseRecord

      payment = Db::Payment.find(params[:id])

      result = Payments::CreatePayment.new(payment: payment).create
      result.success do |payment_url:|
        payment.update(payment_url: payment_url)
        redirect_to payment_url, alert: 'Stworzono link do płatności'
      end
      result.wrong_payment_url { |message:| redirect_to root_path, alert: message }
      result.dotpay_request_error do |message:|
        if Rails.env.development?
          payment.update(payment_url: "http://localhost:3002/business/sign_ups/#{payment.payable_id}/edit", state: 'prepaid')
          redirect_to payment.payment_url, alert: 'Stworzono link do płatności'
        else
          redirect_to root_path, alert: message
        end
      end
    end
  end
end
