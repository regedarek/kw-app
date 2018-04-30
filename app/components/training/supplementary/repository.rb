module Training
  module Supplementary
    class Repository
      def fetch_courses
        Training::Supplementary::CourseRecord.all.collect do |record|
          Training::Supplementary::Course.from_record(record)
        end
      end

      def create(form_outputs:)
        record = Training::Supplementary::CourseRecord.create!(form_outputs.to_h)
        Training::Supplementary::Course.from_record(record)
      end
    end
  end
end
