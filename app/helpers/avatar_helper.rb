module AvatarHelper
  # Safely loads avatar URL with graceful fallback
  # 
  # Handles OpenStack timeouts and CarrierWave errors without crashing the page
  # Returns default avatar image if loading fails
  #
  # @param user [Db::User] User object with avatar uploader
  # @param default [String] Default image path (default: 'default-avatar.png')
  # @param size [Symbol] Avatar size variant if needed
  # @return [String] Avatar URL or default image URL
  #
  # Usage:
  #   = image_tag(safe_avatar_url(current_user), class: 'avatar')
  #   = image_tag(safe_avatar_url(user, default: 'fallback.png'), class: 'avatar')
  #
  def safe_avatar_url(user, default: 'default-avatar.png', size: nil)
    return ActionController::Base.helpers.image_url(default) unless user&.avatar&.present?
    
    # Try to get avatar URL with timeout protection
    url = if size
      user.avatar.url(size)
    else
      user.avatar.url
    end
    
    url
  rescue StandardError => e
    # Log error for monitoring but don't crash the page
    Rails.logger.error "[AvatarHelper] Failed to load avatar for user #{user.id}: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.first(5).join("\n") if Rails.env.development?
    
    # Return default avatar
    ActionController::Base.helpers.image_url(default)
  end
  
  # Check if user has avatar without triggering OpenStack API call
  # Uses database field instead of CarrierWave's present? method
  #
  # @param user [Db::User] User object
  # @return [Boolean] true if avatar column is not nil/empty
  def has_avatar?(user)
    user&.avatar&.file.present?
  rescue StandardError
    false
  end
end