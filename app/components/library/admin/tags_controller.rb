module Library
  module Admin
    class TagsController < ApplicationController
      include EitherMatcher
      append_view_path 'app/components'

      def index
        @parent_tags = Library::TagRecord.where(id: Library::TagRecord.where.not(parent_id: nil).map(&:parent_id))
        @tags = ::Library::TagRecord.all
      end

      def new
        @tag = Library::TagRecord.new
      end

      def show
        @tag = Library::TagRecord.find(params[:id])
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
        params.require(:tag).permit(:name, :description, :parent_id)
      end
    end
  end
end
