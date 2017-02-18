module Importing
  class FromCsv
    class << self
      def import(file:)
        result = Importing::CsvParser.parse(file: file)
        result.failure { return result }
        result.success do |parsed_data:|
          return Importing::Store.store(parsed_data)
        end
      end
    end
  end
end
