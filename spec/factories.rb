def load_fixture(fixture)
  path = File.join(%w(spec fixtures) << (fixture + '.json'))
  file = File.read(path)
  ActiveSupport::JSON.decode(file)[fixture]
end

module Factories
  class User
    def self.create!(attrs = {})
      Db::User.create!(load_fixture('users').sample.merge(attrs))
    end
  end
end
