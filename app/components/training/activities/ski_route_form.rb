require 'i18n'
require 'dry-validation'

module Training
  module Activities
    SkiRouteForm = Dry::Validation.Params do
      configure do
        config.messages = :i18n
        config.messages_file = 'app/components/training/errors.yml'
        config.namespace = :ski_route
      end

      required(:name).filled(:str?)
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
      optional(:photos_attributes).maybe
      optional(:gps_tracks).maybe
      validate(gps_tracks_extension: :gps_tracks) do |tracks|
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
