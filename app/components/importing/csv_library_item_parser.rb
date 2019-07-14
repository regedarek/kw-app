require 'results'

module Importing
  class CsvLibraryItemParser
    class << self
      REQUIRED_LIBRARY_ITEM_HEADERS = %w(
        doc_type title editors year item_id reading_room autors
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

          parsed_object = Importing::LibraryItem.new(
            doc_type: (row['doc_type'] == 'przewodnik' ? 2 : 0),
            title: row['title'],
            item_id: row['item_id'].to_i,
            reading_room: (row['reading_room'] == 'czytelnia' ? true : false),
            autors: row['autors'],
            editors: row['editors'],
            year: row['year'].to_i == 0 ? nil : row['year'].to_i
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
          errors << "Line #{key}: #{value}"
        end

        Failure.new(:invalid, message: "Invalid fields: #{errors.join('; ')}")
      end

      def check_headers(row)
        missing_headers = REQUIRED_LIBRARY_ITEM_HEADERS - row.headers

        if missing_headers.any?
          return Failure.new(:invalid, message: "missing columns: #{missing_headers.join(', ')}")
        end

        extra_headers = row.headers - REQUIRED_LIBRARY_ITEM_HEADERS

        if extra_headers.any?
          return Failure.new(:invalid, message: "extra columns: #{extra_headers.join(', ')}")
        end

        Success.new
      end
    end
  end
end
