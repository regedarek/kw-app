require "dry/matcher/result_matcher"

module ProfileCreation
  module V2
    class ProfilesController < ApplicationController
      append_view_path 'app/components'

      def new
        @profile = Db::Profile.new
      end

      def create
        I18n.locale = params[:locale] || I18n.default_locale
        Dry::Matcher::ResultMatcher.(ProfileCreation::Operation::Create.new.(params: params.to_unsafe_h)) do |result|
          result.success do |profile|
            redirect_to root_path, notice: t('.success')
          end

          result.failure :not_found do |code, errors|
            redirect_to root_path, alert: t('.not_found'), status: :not_found
          end

          result.failure :invalid do |code, profile|
            @profile = profile
            I18n.locale = profile.locale
            render :new
          end

          result.failure :unauthorized do |code, errors|
            redirect_to root_path, alert: t('.unauthorized'), status: :unauthorized
          end

          result.failure do |errors|
            redirect_to root_path, alert: t('.failure'), status: :unprocessable_entity
          end
        end
      end
    end
  end
end
