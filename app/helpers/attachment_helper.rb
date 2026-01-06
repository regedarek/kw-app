module AttachmentHelper
  # Universal helper to safely check if an attachment is an image
  # Works with both Storage::UploadRecord (has content_type) and direct CarrierWave uploaders
  # Avoids EOFError by using cached content_type when available, falling back to extension
  #
  # @param file [CarrierWave::Uploader, Storage::UploadRecord] File uploader or upload record
  # @return [Boolean] true if file is an image, false otherwise
  #
  # Usage in views:
  #   - attachments.select { |file| !safe_image_check?(file) }.each do |attachment|
  #     # Render non-image attachments
  #
  #   - attachments.select { |file| safe_image_check?(file) }.each do |photo|
  #     # Render image attachments
  #
  def safe_image_check?(file)
    return false if file.blank?
    
    begin
      # Strategy 1: Check if it's a Storage::UploadRecord with cached content_type
      if file.respond_to?(:content_type) && file.content_type.present?
        return file.content_type.start_with?('image')
      end
      
      # Strategy 2: Check if it's an uploader instance with a model that has content_type
      if file.respond_to?(:model) && file.model.respond_to?(:content_type) && file.model.content_type.present?
        return file.model.content_type.start_with?('image')
      end
      
      # Strategy 3: Fall back to file extension (fast, no file I/O)
      path = if file.respond_to?(:path)
        file.path
      elsif file.respond_to?(:file) && file.file.respond_to?(:path)
        file.file.path
      else
        return false
      end
      
      extension = File.extname(path).downcase.delete('.')
      image_extensions = %w[jpg jpeg png gif webp bmp tiff svg ico]
      
      return image_extensions.include?(extension)
      
    rescue => e
      # Log error but don't crash the page
      Rails.logger.error "[AttachmentHelper] Error checking if file is image: #{e.class} - #{e.message}"
      Rails.logger.error "[AttachmentHelper] File class: #{file.class.name}"
      
      # Default to false on error
      return false
    end
  end
  
  # Inverse of safe_image_check? for readability
  #
  # Usage:
  #   - attachments.select { |file| safe_document_check?(file) }.each do |doc|
  #
  def safe_document_check?(file)
    !safe_image_check?(file)
  end
  
  # Get the content type of an attachment safely
  # Returns cached value if available, otherwise detects from extension
  #
  # @param file [CarrierWave::Uploader, Storage::UploadRecord] File uploader or upload record
  # @return [String, nil] Content type (e.g., 'image/jpeg') or nil
  #
  def safe_content_type(file)
    return nil if file.blank?
    
    begin
      # Check cached content_type
      if file.respond_to?(:content_type) && file.content_type.present?
        return file.content_type
      end
      
      if file.respond_to?(:model) && file.model.respond_to?(:content_type) && file.model.content_type.present?
        return file.model.content_type
      end
      
      # Fall back to extension-based detection
      path = if file.respond_to?(:path)
        file.path
      elsif file.respond_to?(:file) && file.file.respond_to?(:path)
        file.file.path
      else
        return nil
      end
      
      extension = File.extname(path).downcase.delete('.')
      content_type_from_extension(extension)
      
    rescue => e
      Rails.logger.error "[AttachmentHelper] Error getting content type: #{e.class} - #{e.message}"
      nil
    end
  end
  
  private
  
  # Map file extension to content type
  # This is fast and doesn't require reading the file
  def content_type_from_extension(extension)
    case extension
    when 'jpg', 'jpeg' then 'image/jpeg'
    when 'png' then 'image/png'
    when 'gif' then 'image/gif'
    when 'webp' then 'image/webp'
    when 'bmp' then 'image/bmp'
    when 'tiff', 'tif' then 'image/tiff'
    when 'svg' then 'image/svg+xml'
    when 'ico' then 'image/x-icon'
    when 'pdf' then 'application/pdf'
    when 'doc' then 'application/msword'
    when 'docx' then 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    when 'xls' then 'application/vnd.ms-excel'
    when 'xlsx' then 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    when 'ppt' then 'application/vnd.ms-powerpoint'
    when 'pptx' then 'application/vnd.openxmlformats-officedocument.presentationml.presentation'
    when 'zip' then 'application/zip'
    when 'rar' then 'application/x-rar-compressed'
    when '7z' then 'application/x-7z-compressed'
    when 'txt' then 'text/plain'
    when 'csv' then 'text/csv'
    when 'json' then 'application/json'
    when 'xml' then 'application/xml'
    when 'gpx' then 'application/gpx+xml'
    when 'mp4' then 'video/mp4'
    when 'avi' then 'video/x-msvideo'
    when 'mov' then 'video/quicktime'
    when 'wmv' then 'video/x-ms-wmv'
    when 'mp3' then 'audio/mpeg'
    when 'wav' then 'audio/wav'
    when 'ogg' then 'audio/ogg'
    else nil
    end
  end
end