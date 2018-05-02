module Training
  module Supplementary
    class Repository
      def fetch_courses
        Training::Supplementary::CourseRecord.all.order(:application_date).collect do |record|
          Training::Supplementary::Course.from_record(record)
        end
      end

      def create(form_outputs:)
        o_id = form_outputs[:organizator_id]&.first if form_outputs.to_h.include?(:organizator_id)
        record = Training::Supplementary::CourseRecord
          .create!(form_outputs.to_h.merge!(organizator_id: o_id))
        Training::Supplementary::Course.from_record(record)
      end
    end
  end
end
