module Importing
  class Store
    class << self
      def store(parsed_objects)
        Db::Activities::MountainRoute.transaction do
          parsed_objects.each do |parsed_data|
            Db::Activities::MountainRoute.new.update!(
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
    end
  end
end
