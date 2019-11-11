module Blog
  class Authors
    def fetch
      {
        authors: authors.map do |user|
          ::Blog::Author.from_record(user)
        end,
        mjs: mjs.map do |user|
          ::Blog::Author.from_record(user)
        end,
        instructors: instructors.map do |user|
          ::Blog::Author.from_record(user)
        end,
        management: management.map do |user|
          ::Blog::Author.from_record(user)
        end,
        sport: sport.map do |user|
          ::Blog::Author.from_record(user)
        end,
        gear: gear.map do |user|
          ::Blog::Author.from_record(user)
        end,
        support: support.map do |user|
          ::Blog::Author.from_record(user)
        end
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
      Db::User.includes(:profile, :mountain_routes).where(":name = ANY(snw_groups)", name: "authors").where.not(author_number: nil).order('profiles.application_date')
    end

    def mjs
      group_users('mjs')
    end

    def instructors
      group_users('instructors')
    end

    def management
      group_users('management')
    end

    def sport
      group_users('sport')
    end

    def gear
      group_users('gear')
    end

    def support
      group_users('support')
    end

    def group_users(group)
      Db::User.includes(:profile, :mountain_routes).where(":name = ANY(snw_groups)", name: group).where.not(snw_blog: false).order('profiles.application_date')
    end
  end
end
