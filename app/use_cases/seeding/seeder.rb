require './spec/factories'

module Seeding
  class Seeder
    class << self
      def seed!
        Db::Membership::Fee.destroy_all
        Factories::Membership::Fee.mass_create!(range: (1..20), state: 'prepaid', cash: false)
        Factories::Membership::Fee.mass_create!(range: (21..40), state: 'unpaid', cash: true)
        Factories::Membership::Fee.mass_create!(range: (41..50), state: 'unpaid', cash: false)
        Factories::Membership::Fee.mass_create!(range: (51..80), state: 'prepaid', cash: true)
        Factories::Membership::Fee.mass_create!(range: (81..100), state: 'prepaid', cash: false)
        Db::Profile.destroy_all
        (1..80).step(1) do |i|
          profile = Factories::Profile.create!(
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            email: Faker::Internet.unique.email,
            phone: Faker::PhoneNumber.cell_phone,
            position: 2.times.map { Db::Profile::POSITION.sample }.uniq,
            acomplished_courses: 2.times.map { Db::Profile::ACOMPLISHED_COURSES.sample }.uniq,
            sections: 2.times.map { Db::Profile::SECTIONS.sample }.uniq,
            recommended_by: 3.times.map { Db::Profile::RECOMMENDED_BY.sample }.uniq,
            cost: [100, 50, 150].sample,
            added: [true, false].sample,
            accepted: false,
            main_discussion_group: [true, false].sample,
            application_date: Faker::Date.birthday(18, 65),
            birth_date: Faker::Date.birthday(18, 65),
            kw_id: nil,
            city: Faker::Address.city,
            birth_place: Faker::Address.city,
            pesel: Faker::Code.ean,
            postal_code: Faker::Address.postcode,
            main_address: Faker::Address.street_address,
            optional_address: Faker::Address.secondary_address
          )
          profile.create_payment(dotpay_id: SecureRandom.hex(13))
        end
        (81..100).step(1) do |i|
          profile = Factories::Profile.create!(
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            email: Faker::Internet.unique.email,
            phone: Faker::PhoneNumber.cell_phone,
            position: 2.times.map { Db::Profile::POSITION.sample }.uniq,
            acomplished_courses: 2.times.map { Db::Profile::ACOMPLISHED_COURSES.sample }.uniq,
            sections: 2.times.map { Db::Profile::SECTIONS.sample }.uniq,
            recommended_by: 3.times.map { Db::Profile::RECOMMENDED_BY.sample }.uniq,
            cost: [100, 50, 150].sample,
            added: [true, false].sample,
            accepted: true,
            main_discussion_group: [true, false].sample,
            application_date: Faker::Date.birthday(18, 65),
            birth_date: Faker::Date.birthday(18, 65),
            kw_id: i,
            city: Faker::Address.city,
            birth_place: Faker::Address.city,
            pesel: Faker::Code.ean,
            postal_code: Faker::Address.postcode,
            main_address: Faker::Address.street_address,
            optional_address: Faker::Address.secondary_address
          )
          profile.create_payment(dotpay_id: SecureRandom.hex(13), cash: false, state: 'prepaid')
        end
        Db::User.destroy_all
        Db::Profile.where(kw_id: (81..100)).each do |profile|
          user = Db::User.create!(kw_id: profile.kw_id, first_name: profile.first_name, last_name: profile.last_name, email: profile.email, phone: profile.phone)
          user.password = "test#{profile.id}"
          user.save
        end
        Factories::Profile.create!(
          first_name: 'Dariusz',
          last_name: 'Finster',
          email: 'dariusz.finster@gmail.com',
          phone: Faker::PhoneNumber.cell_phone,
          position: 2.times.map { Db::Profile::POSITION.sample }.uniq,
          acomplished_courses: 2.times.map { Db::Profile::ACOMPLISHED_COURSES.sample }.uniq,
          sections: 2.times.map { Db::Profile::SECTIONS.sample }.uniq,
          recommended_by: 3.times.map { Db::Profile::RECOMMENDED_BY.sample }.uniq,
          cost: [100, 50, 150].sample,
          added: [true, false].sample,
          accepted: true,
          main_discussion_group: [true, false].sample,
          application_date: Faker::Date.birthday(18, 65),
          birth_date: Faker::Date.birthday(18, 65),
          kw_id: 2345,
          city: Faker::Address.city,
          birth_place: Faker::Address.city,
          pesel: Faker::Code.ean,
          postal_code: Faker::Address.postcode,
          main_address: Faker::Address.street_address,
          optional_address: Faker::Address.secondary_address
        )
        user1 = Db::User.new(
          first_name: 'Małgorzata',
          last_name: 'Kozak',
          email: 'm.kozak1980@gmail.com',
          kw_id: 1720,
          phone: Faker::PhoneNumber.cell_phone,
          admin: true
        )
        user1.password = "test"
        user1.save
        user2 = Db::User.new(
          first_name: 'Bartłomiej',
          last_name: 'Klimas',
          email: 'klimas.bartlomiej@gmail.com',
          kw_id: 1720,
          phone: Faker::PhoneNumber.cell_phone,
          admin: true
        )
        user2.password = "test"
        user2.save
        user3 = Db::User.create(
          first_name: 'Dariusz',
          last_name: 'Finster',
          email: 'dariusz.finster@gmail.com',
          kw_id: 2345,
          phone: Faker::PhoneNumber.cell_phone,
          admin: true,
        )
        user3.password = "test"
        user3.save
        Db::Item.destroy_all
        (1..10).step(1) do |n|
          Factories::Item.create!(id: n, display_name: Faker::Commerce.product_name, owner: ['snw', 'kw'].sample)
        end
      end
    end
  end
end
