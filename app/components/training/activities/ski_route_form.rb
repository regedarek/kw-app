module Training
  module Activities
    class SkiRouteForm < Dry::Validation::Contract
      config.messages.load_paths << 'app/components/training/errors.yml'
      config.messages.namespace = :ski_route

        params do 
      required(:name).filled(:string)
      required(:climbing_date).filled
      required(:colleague_ids).filled
      optional(:rating).filled
      optional(:partners)
      optional(:photograph)
      optional(:difficulty)
      optional(:area)
      optional(:length)
      optional(:description)
      optional(:contract_ids)
      optional(:attachments)
      optional(:photos_attributes)
      optional(:gps_tracks)
        end
      rule(:gps_tracks) do |tracks|
        if tracks.present?
          tracks.all? do |track|
            File.extname(track.original_filename) == '.gpx'
          end
        else
          true
        end
      end
    end
  end
end
