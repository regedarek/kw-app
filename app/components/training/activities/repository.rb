module Training
  module Activities
    class Repository
      def create(form_outputs:)
        record = ::Db::Activities::MountainRoute
          .create!(form_outputs.to_h)

        Training::Activities::SkiRoute.from_record(record)
      end
    end
  end
end
