def load_fixture(fixture)
  path = File.join(%w(spec fixtures) << (fixture + '.json'))
  file = File.read(path)
  ActiveSupport::JSON.decode(file)[fixture]
end

module Factories
  class User
    def self.create!(attrs = {})
      Db::User.create!(load_fixture('users').first.merge(attrs))
    end
  end

  class Item
    def self.create!(attrs = {}, id: 1)
      Db::Item.create!(load_fixture('items')[id - 1].merge(attrs))
    end

    def self.create_all!
      load_fixture('items').each do |item_json|
        Db::Item.create!(item_json)
      end
      Db::Item.all
    end
  end

  class Reservation
    def self.create!(attrs = {}, id: 1)
      Db::Reservation.create!(load_fixture('reservations')[id - 1].merge(attrs))
    end

    def self.build_form(attrs = {})
      ::Reservations::Form.new({
        start_date: '2016-08-18',
        end_date: '2016-08-25',
        item_ids: [1]
      }.merge(attrs))
    end
  end
end
