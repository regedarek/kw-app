module Importing
  class CsvProfileParser
    class << self
      REQUIRED_PROFILE_HEADERS = %w(
        kw_id birth_date birth_place pesel city postal_code main_address optional_address recommended_by acomplished_courses main_discussion_group sections
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

          parsed_object = Importing::Profile.new(
            birth_date: row['birth_date'],
            birth_place: row['birth_place'],
            pesel: row['pesel'],
            city: row['city'],
            postal_code: row['postal_code'],
            main_address: row['main_address'],
            optional_address: row['optional_address'],
            recommended_by: row['recommended_by'],
            acomplished_course: row['acomplished_course'],
            main_discussion_group: row['main_discussion_group'],
            section: row['section'],
            kw_id: row['kw_id']
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

      def parsed_profile(row)
        Importing::Profile.new(
          birth_date: row['birth_date'],
          birth_place: row['birth_place'],
          pesel: row['pesel'],
          city: row['city'],
          postal_code: row['postal_code'],
          main_address: row['main_address'],
          optional_address: row['optional_address'],
          recommended_by: row['recommended_by'],
          acomplished_course: row['acomplished_course'],
          main_discussion_group: row['main_discussion_group'],
          section: row['section'],
          kw_id: row['kw_id']
        )
      end

      def failure_with_lines(invalid_lines)
        errors = []

        invalid_lines.each do |key, value|
          errors << "Line #{key}: #{value.keys.join(', ')}"
        end

        Failure.new(:invalid, message: "Invalid fields: #{errors.join('; ')}")
      end

      def check_headers(row)
        missing_headers = REQUIRED_PROFILE_HEADERS - row.headers

        if missing_headers.any?
          return Failure.new(:invalid, message: "missing columns: #{missing_headers.join(', ')}")
        end

        extra_headers = row.headers - REQUIRED_PROFILE_HEADERS

        if extra_headers.any?
          return Failure.new(:invalid, message: "extra columns: #{extra_headers.join(', ')}")
        end

        Success.new
      end
    end
  end
end
