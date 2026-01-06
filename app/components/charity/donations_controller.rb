module Charity
  class DonationsController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'
    def new
      @donation = Charity::DonationRecord.new
    end

    def create
      result = create_record
      
      result.success do |payment:|
        redirect_to charge_payment_path(payment.id)
      end
      
      result.invalid do |message:|
        flash[:error] = message
        redirect_to michal_path
      end
      
      result.else_fail!
    end

    private

    def create_record
      Charity::CreateDonation.new(
        Charity::Repository.new,
        Charity::DonationForm.new
      ).call(raw_inputs: donation_params)
    end

    def donation_params
      params
        .require(:donation)
        .permit(
          :cost,
          :user_id,
          :action_type,
          :display_name,
          :terms_of_service
        )
    end
  end
end
