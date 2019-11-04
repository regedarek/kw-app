module Blog
  class Authors
    def fetch
      {
        authors: authors.map do |user|
          ::Blog::Author.from_record(user)
        end,
        active_members: active_members.map do |user|
          ::Blog::Author.from_record(user)
        end,
        rest_members: rest_members
      }
    end

    def fetch_one(number: nil)
      return {} if number.nil?
      return {} if number.empty?

      user = Db::User.find_by(author_number: number)
      ::Blog::Author.from_record(user)

    rescue
      return {}
    end

    private

    def authors
      Db::User.includes(:profile, :mountain_routes).where.not(author_number: nil).order('profiles.application_date')
    end

    def active_members
      Db::User.includes(:profile, :mountain_routes).where(author_number: nil, snw_blog: true).order('profiles.application_date')
    end

    def rest_members
      Db::User.includes(:profile, :mountain_routes).where(author_number: nil, snw_blog: false).active.where('sections @> array[?]', 'snw').order('profiles.application_date')
    end
  end
end
