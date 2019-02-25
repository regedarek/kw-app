module Charity
  class DonationsController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'
    def new
      @donation = Charity::DonationRecord.new
    end

    def create
      either(create_record) do |result|
        result.success { redirect_to admin_contracts_path }

        result.failure do |errors|
          flash[:error] = errors.values.join(", ")
          render :new
        end
      end
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
          :display_name
        )
    end
  end
end
