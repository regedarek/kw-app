# Fix for CarrierWave fog storage nil content_length bug
# 
# Issue: When OpenStack API is slow or times out, file.content_length returns nil
# This causes a crash when CarrierWave calls size.zero? on nil
#
# Error: undefined method `zero?' for nil:NilClass
# Location: carrierwave/storage/fog.rb in empty? method
#
# This monkey patch ensures size always returns a number, never nil

module CarrierWave
  module Storage
    class Fog < Abstract
      class File
        # Override size to handle nil content_length gracefully
        # Original implementation can return nil when OpenStack API fails
        def size
          return 0 if file.nil?
          
          content_length = file.content_length
          
          # Guard against nil content_length from fog/OpenStack
          content_length.nil? ? 0 : content_length
        rescue StandardError => e
          # Log error but don't crash
          Rails.logger.error "CarrierWave::Storage::Fog::File#size failed: #{e.class} - #{e.message}"
          0
        end
      end
    end
  end
end