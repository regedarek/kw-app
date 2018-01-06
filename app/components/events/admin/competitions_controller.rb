module Events
  module Admin
    class CompetitionsController < ::Admin::BaseController
      prepend_view_path 'app/components/events/views'

      def index
        @competitions = Events::Db::CompetitionRecord.all
      end

      def new
      end

      def create
      end
    end
  end
end
