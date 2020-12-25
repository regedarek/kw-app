module Management
  module News
    module Api
      class InformationsController < ApplicationController
        include Pagy::Backend
        after_action { pagy_headers_merge(@pagy) if @pagy }

        def index
          informations = InformationRecord.order(created_at: :desc).all
          informations = informations.where(news_type: params[:news_type]) if params[:news_type]
          informations = informations.where(group_type: params[:group_type]) if params[:group_type]
          informations = informations.order(params[:order] => :desc) if params[:order]

          @pagy, records = pagy(informations)

          render json: records, each_serializer: Training::Supplementary::Serializers::CourseSerializer
        end
      end
    end
  end
end
