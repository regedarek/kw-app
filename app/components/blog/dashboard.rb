module Blog
  class Dashboard
    def fetch
      Db::User.all
    end
  end
end
