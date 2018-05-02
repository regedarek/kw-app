module Training
  module Supplementary
    class Repository
      def fetch_courses
        Training::Supplementary::CourseRecord.all.collect do |record|
          Training::Supplementary::Course.from_record(record)
        end
      end

      def create(form_outputs:)
        o_id = form_outputs[:organizator_id]&.first
        record = Training::Supplementary::CourseRecord
          .create!(form_outputs.to_h.merge!(organizator_id: o_id))
        Training::Supplementary::Course.from_record(record)
      end
    end
  end
end
