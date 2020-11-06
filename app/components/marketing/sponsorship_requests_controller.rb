module Marketing
  class SponsorshipRequestsController < ApplicationController
    append_view_path 'app/components'

    def index
      @sponsorship_requests = Marketing::SponsorshipRequestRecord.all
    end

    def new
      @sponsorship_request = Marketing::SponsorshipRequestRecord.new
    end

    def create
      @sponsorship_request = Marketing::SponsorshipRequestRecord.new(sponsorship_request_params)

      if @sponsorship_request.save
        redirect_to sponsorship_requests_path, notice: 'Dodano'
      else
        render :new
      end
    end

    def show
      @sponsorship_request = Marketing::SponsorshipRequestRecord.find(params[:id])
    end

    private

    def sponsorship_request_params
      params.require(:sponsorship_request).permit(:user_id, :contractor_id, :description, :state, :sent_at, :doc_url)
    end
  end
end
