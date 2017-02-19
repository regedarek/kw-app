module Importing
  class CsvMountainRouteParser
    class << self
      REQUIRED_MOUNTAIN_ROUTE_HEADERS = %w(
        route_type name description difficulty partners time climbing_date rating area
      )

      def parse(file:)
        parsed_data = []
        invalid_lines = {}
        return Failure.new(:invalid, message: I18n.t('.empty_file')) if file.size.zero?

        CSV.open(file.path, col_sep: ';', headers: true).each_with_index do |row, index|
          next if row.empty?

          if index == 0
            result = check_headers(row)
            return result if result.failure?
          end

          parsed_object = Importing::MountainRoute.new(
            route_type: row['route_type'],
            name: row['name'],
            area: row['area'],
            description: row['description'],
            difficulty: row['difficulty'],
            partners: row['partners'],
            time: row['time'],
            climbing_date: row['climbing_date'],
            rating: row['rating']
          )

          if parsed_object.invalid?
            invalid_lines[index + 1] = parsed_object.errors.messages
          else
            parsed_data << parsed_object
          end
        end

        return failure_with_lines(invalid_lines) if invalid_lines.any?

        Success.new(parsed_data: parsed_data)
      end

      private

      def failure_with_lines(invalid_lines)
        errors = []

        invalid_lines.each do |key, value|
          errors << "Line #{key}: #{value.keys.join(', ')}"
        end

        Failure.new(:invalid, message: "Invalid fields: #{errors.join('; ')}")
      end

      def check_headers(row)
        missing_headers = REQUIRED_MOUNTAIN_ROUTE_HEADERS - row.headers

        if missing_headers.any?
          return Failure.new(:invalid, message: "missing columns: #{missing_headers.join(', ')}")
        end

        extra_headers = row.headers - REQUIRED_MOUNTAIN_ROUTE_HEADERS

        if extra_headers.any?
          return Failure.new(:invalid, message: "extra columns: #{extra_headers.join(', ')}")
        end

        Success.new
      end
    end
  end
end
