module Training
  module Activities
    class GpsTrackUploader < ApplicationUploader

      def store_dir
        "mountain_routes/gps_tracks/#{model.id}"
      end
    end
  end
end
