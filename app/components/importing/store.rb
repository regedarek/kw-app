module Importing
  class Store
    class << self
      def store_profile_update(parsed_objects)
        Db::Profile.transaction do
          parsed_objects.each do |parsed_data|
            profile = Db::Profile.find_by(email: parsed_data.email)
            profile.update(
              sections: parsed_data.sections,
              acomplished_courses: parsed_data.acomplished_courses,
              profession: parsed_data.profession
            ) if profile
          end
        end

        return Success.new
      end

      def store_library_item(parsed_objects)
        Library::ItemRecord.transaction do
          parsed_objects.each do |parsed_data|
            library_item = Library::ItemRecord.create(
              doc_type: parsed_data.doc_type,
              title: parsed_data.title,
              description: parsed_data.description,
              item_id: parsed_data.item_id,
              reading_room: parsed_data.reading_room
            )
            parsed_data.autors.split(",").map(&:strip).each do |author_name|
              author = Library::AuthorRecord.where(name: author_name).first_or_create
              Library::ItemAuthorsRecord.where(author_id: author.id, item_id: library_item.id).first_or_create
            end if parsed_data.autors
          end
        end

        return Success.new
      end

      def store_mountain_route(parsed_objects)
        Db::Activities::MountainRoute.transaction do
          parsed_objects.each do |parsed_data|
            mountain_route = Db::Activities::MountainRoute.new.update(
              route_type: parsed_data.route_type,
              name: parsed_data.name,
              area: parsed_data.area,
              length: parsed_data.length,
              peak: parsed_data.peak,
              mountains: parsed_data.mountains,
              description: parsed_data.description,
              difficulty: parsed_data.difficulty,
              partners: parsed_data.partners,
              time: parsed_data.time,
              climbing_date: parsed_data.climbing_date,
              rating: parsed_data.rating
            )
          end
        end

        return Success.new
      end

      def store_user(parsed_objects)
        Db::User.transaction do
          parsed_objects.each do |parsed_data|
            Db::User.new.update(
              first_name: parsed_data.first_name,
              last_name: parsed_data.last_name,
              email: parsed_data.email,
              phone: parsed_data.phone,
              kw_id: parsed_data.kw_id,
              password: parsed_data.password
            )
          end
        end

        return Success.new
      end

      def store_membership_fee(parsed_objects)
        Db::Membership::Fee.transaction do
          parsed_objects.each do |parsed_data|
           if parsed_data.pesel.present?
             profile = Db::Profile.find_by(pesel: parsed_data.pesel)
             if profile.present? && profile.kw_id.present?
               fee = Db::Membership::Fee.new(
                 year: parsed_data.year,
                 kw_id: profile.kw_id
               )
               if fee.valid?
                 fee.save
                 payment = fee.create_payment(dotpay_id: SecureRandom.hex(13))
                 payment.update(cash: true, state: 'prepaid')
               end
             end
           else
             fee = Db::Membership::Fee.new(
               year: parsed_data.year,
               kw_id: parsed_data.kw_id
             )
             if fee.valid?
               fee.save
               payment = fee.create_payment(dotpay_id: SecureRandom.hex(13))
               payment.update(cash: true, state: 'prepaid')
             else
             end
           end
          end
        end

        return Success.new
      end

      def store_profile(parsed_objects)
        Db::Profile.transaction do
          parsed_objects.each do |parsed_data|
            Db::Profile.new.update(
              first_name: parsed_data.first_name,
              last_name: parsed_data.last_name,
              email: parsed_data.email,
              phone: parsed_data.phone,
              birth_date: parsed_data.birth_date,
              birth_place: parsed_data.birth_place,
              pesel: parsed_data.pesel,
              city: parsed_data.city,
              postal_code: parsed_data.postal_code,
              main_address: parsed_data.main_address,
              optional_address: parsed_data.optional_address,
              recommended_by: parsed_data.recommended_by,
              acomplished_courses: parsed_data.acomplished_courses,
              main_discussion_group: parsed_data.main_discussion_group,
              sections: parsed_data.sections,
              kw_id: parsed_data.kw_id,
              accepted: parsed_data.accepted,
              date_of_death: parsed_data.date_of_death,
              remarks: parsed_data.remarks,
              application_date: parsed_data.application_date,
              profession: parsed_data.profession,
              added: parsed_data.added,
              position: parsed_data.position
           )
          end
        end

        return Success.new
      end
    end
  end
end
