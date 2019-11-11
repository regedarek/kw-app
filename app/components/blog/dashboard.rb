module Blog
  class Dashboard
    def fetch
      {
        latest_degree: Scrappers::ToprRecord.last.topr_degree.url(:normal),
        top_5_boars: top_5_boars,
        total_meters: routes.sum(:length),
        last_route: { name: routes.last.name, date: routes.last.climbing_date },
        max_meters_person: { name: best_person.display_name, meters: top_5_boars.first }
      }.to_json
    end

    private

    def top_5_boars
      Activities::Repository.new.fetch_season(:ski, DateTime.new(2018, 11, 1), DateTime.new(2019, 05, 01)).limit(5).map do |user|
        {
          display_name: Db::User.find_by(kw_id: user.kw_id).display_name,
          meters: user.total_mountain_routes_length,
          avatar: user.avatar.url
        }
      end
    end

    def routes
      Db::Activities::MountainRoute.where(route_type: 'ski').order(:climbing_date)
    end

    def best_person
      kw_id = Activities::Repository.new.fetch_season(:ski).first.kw_id
      Db::User.find_by(kw_id: kw_id)
    end
  end
end
