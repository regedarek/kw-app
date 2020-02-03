module Blog
  class Dashboard
    def fetch
      {
        latest_degree: Scrappers::ToprRecord.last.topr_degree.url(:dashboard),
        top_5_boars: top_5_boars,
        total_meters: routes.sum(:length),
        last_route: { name: routes.last.name, date: routes.last.climbing_date },
        max_meters_person: { name: Db::User.find_by(kw_id: best_person.kw_id).display_name, meters: best_person.total_mountain_routes_length }
      }.to_json
    end

    private

    def latest_degree
      today_infos = Scrappers::ToprRecord.where(time: Date.today).order(time: :desc)

      if today_infos.any?
        today_infos.first.topr_degree.url(:dashboard)
      else
        'brak zagrożenia'
      end
    end

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
      Activities::Repository.new.fetch_season(:ski, DateTime.new(2019, 11, 1), DateTime.new(2020, 05, 01)).first
    end
  end
end
