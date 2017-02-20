module Importing
  class Store
    class << self
      def store_mountain_route(parsed_objects)
        Db::Activities::MountainRoute.transaction do
          parsed_objects.each do |parsed_data|
            mountain_route = Db::Activities::MountainRoute.new.update(
              route_type: parsed_data.route_type,
              name: parsed_data.name,
              area: parsed_data.area,
              description: parsed_data.description,
              difficulty: parsed_data.difficulty,
              partners: parsed_data.partners,
              time: parsed_data.time,
              climbing_date: parsed_data.climbing_date,
              rating: parsed_data.rating,
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
        Db::MembershipFee.transaction do
          parsed_objects.each do |parsed_data|
           fee = Db::MembershipFee.create(
             year: parsed_data.year,
             kw_id: parsed_data.kw_id
           )
           order = Orders::CreateOrder.new(service: fee).create
           order.payment.update(cash: true)
          end
        end

        return Success.new
      end

      def store_profile(parsed_objects)
        Db::Profile.transaction do
          parsed_objects.each do |parsed_data|
            Db::Profile.new.update(
              birth_date: parsed_data.birth_date,
              birth_place: parsed_data.birth_place,
              pesel: parsed_data.pesel,
              city: parsed_data.city,
              postal_code: parsed_data.postal_code,
              main_address: parsed_data.main_address,
              optional_address: parsed_data.optional_address,
              recommended_by: parsed_data.recommended_by,
              acomplished_course: parsed_data.acomplished_course,
              main_discussion_group: parsed_data.main_discussion_group,
              section: parsed_data.section,
              kw_id: parsed_data.kw_id,
            )
          end
        end

        return Success.new
      end
    end
  end
end
