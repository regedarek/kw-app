require './spec/factories'

module Seeding
  class Seeder
    class << self
      def seed!
        Db::Membership::Fee.destroy_all
        Factories::Membership::Fee.mass_create!(range: (1..20), state: 'prepaid', cash: false)
        Factories::Membership::Fee.mass_create!(range: (21..40), state: 'unpaid', cash: true)
        Factories::Membership::Fee.mass_create!(range: (41..50), state: 'unpaid', cash: false)
        Factories::Membership::Fee.mass_create!(range: (51..70), state: 'prepaid', cash: true)
        Db::Profile.destroy_all
        (1..80).step(1) do |i|
          Factories::Profile.create!(
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            email: Faker::Internet.unique.email,
            phone: Faker::PhoneNumber.cell_phone,
            position: 2.times.map { Db::Profile::POSITION.sample },
            acomplished_courses: 2.times.map { Db::Profile::ACOMPLISHED_COURSES.sample },
            sections: 2.times.map { Db::Profile::SECTIONS.sample },
            recommended_by: 3.times.map { Db::Profile::RECOMMENDED_BY.sample },
            cost: [100, 50, 150].sample,
            added: [true, false].sample,
            accepted: false,
            main_discussion_group: [true, false].sample,
            application_date: Faker::Date.birthday(18, 65),
            birth_date: Faker::Date.birthday(18, 65)
            kw_id: nil,
            city: Faker::Address.city,
            birth_place: Faker::Address.city,
            pesel: Faker::Code.ean,
            postal_code: Faker::Address.postcode,
            main_address: Faker::Address.street_address,
            optional_address: Faker::Address.secondary_address
          )
        end
        (81..100).step(1) do |i|
          Factories::Profile.create!(
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            email: Faker::Internet.unique.email,
            phone: Faker::PhoneNumber.cell_phone,
            position: 2.times.map { Db::Profile::POSITION.sample },
            acomplished_courses: 2.times.map { Db::Profile::ACOMPLISHED_COURSES.sample },
            sections: 2.times.map { Db::Profile::SECTIONS.sample },
            recommended_by: 3.times.map { Db::Profile::RECOMMENDED_BY.sample },
            cost: [100, 50, 150].sample,
            added: [true, false].sample,
            accepted: true,
            main_discussion_group: [true, false].sample,
            application_date: Faker::Date.birthday(18, 65),
            birth_date: Faker::Date.birthday(18, 65)
            kw_id: i,
            city: Faker::Address.city,
            birth_place: Faker::Address.city,
            pesel: Faker::Code.ean,
            postal_code: Faker::Address.postcode,
            main_address: Faker::Address.street_address,
            optional_address: Faker::Address.secondary_address
          )
        end
        Db::User.destroy_all
        Db::Profile.where(id: (81..100)).each do |profile|
          Db::User.create!(kw_id: profile.kw_id, first_name: profile.first_name, last_name: profile: last_name, email: profile.email, phone: profile.phone)
        end
        Factories::Profile.create!(
          first_name: 'Dariusz',
          last_name: 'Finster',
          email: 'dariusz.finster@gmail.com',
          phone: Faker::PhoneNumber.cell_phone,
          position: 2.times.map { Db::Profile::POSITION.sample },
          acomplished_courses: 2.times.map { Db::Profile::ACOMPLISHED_COURSES.sample },
          sections: 2.times.map { Db::Profile::SECTIONS.sample },
          recommended_by: 3.times.map { Db::Profile::RECOMMENDED_BY.sample },
          cost: [100, 50, 150].sample,
          added: [true, false].sample,
          accepted: true,
          main_discussion_group: [true, false].sample,
          application_date: Faker::Date.birthday(18, 65),
          birth_date: Faker::Date.birthday(18, 65)
          kw_id: 2345,
          city: Faker::Address.city,
          birth_place: Faker::Address.city,
          pesel: Faker::Code.ean,
          postal_code: Faker::Address.postcode,
          main_address: Faker::Address.street_address,
          optional_address: Faker::Address.secondary_address
        )
        darek = Db::User.new(
          first_name: 'Dariusz',
          last_name: 'Finster',
          email: 'dariusz.finster@gmail.com',
          kw_id: 2345,
          phone: Faker::PhoneNumber.cell_phone
        )
        darek.password = 'test'
        darek.save
        Db::Item.destroy_all
        (1..10).step(1) do |n|
          Factories::Item.create!(display_name: Faker::Commerce.product_name, owner: ['snw', 'kw'].sample)
        end
      end
    end
  end
end
