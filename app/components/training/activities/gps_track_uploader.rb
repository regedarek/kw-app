module Training
  module Activities
    class GpsTrackUploader < CarrierWave::Uploader::Base
      if Rails.env.production? || Rails.env.staging?
        storage :fog
      else
        storage :file
      end

      def store_dir
        "mountain_routes/gps_tracks/#{model.id}"
      end
    end
  end
end
