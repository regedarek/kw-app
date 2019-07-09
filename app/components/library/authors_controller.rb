module Library
  class AuthorsController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def show
      @author = Library::AuthorRecord.find(params[:id])
    end
  end
end
