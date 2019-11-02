module Blog
  class Authors
    def fetch
      Db::User.includes(:mountain_routes).where.not(author_number: nil).map do |u|
        ::Blog::Author.from_record(u)
      end
    end
  end
end
