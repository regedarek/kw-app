module Blog
  class Authors
    def fetch
      Db::User.includes(:mountain_routes).where.not(author_number: nil).map do |u|
        ::Blog::Author.from_record(u)
      end
    end

    def fetch_one(number: nil)
      return {} if number.nil?
      return {} if number.empty?

      user = Db::User.find_by(author_number: number)
      ::Blog::Author.from_record(user)

    rescue
      return {}
    end
  end
end
