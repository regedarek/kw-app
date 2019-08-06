module Library
  module Admin
    class TagsController < ApplicationController
      include EitherMatcher
      append_view_path 'app/components'

      def index
        @tags = ::Library::TagRecord.all
      end

      def new
        @tag = Library::TagRecord.new
      end

      def create
        @tag = Library::TagRecord.new(tag_params)

        if @tag.save
          redirect_to admin_tags_path, notice: 'Tag dodany!'
        else
          render :new
        end
      end

      private

      def tag_params
        params.require(:tag).permit(:name, :description)
      end
    end
  end
end
