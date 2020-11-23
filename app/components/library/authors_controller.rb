module Library
  class AuthorsController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def show
      @author = Library::AuthorRecord.find(params[:id])
    end

    def new
      @author = Library::AuthorRecord.new
    end

    def create
      @author = Library::AuthorRecord.new(author_params)

      if @author.save
        redirect_to autor_path(@author.id), notice: 'Dodano'
      else
        render :new
      end
    end

    private

    def author_params
      params.require(:author).permit(:name, :description)
    end
  end
end
