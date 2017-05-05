require 'googleauth'

module Groups
  class Manager
    def initialize
      configure_client(Db::User.find_by(email:'dariusz.finster@gmail.com'))
    end

    def configure_client(current_user)
      require 'google/apis/groupssettings_v1'
      @auth = Signet::OAuth2::Client.new(
        client_id: Rails.application.secrets.google_client_id,
        client_secret: Rails.application.secrets.google_client_secret,
        access_token: current_user.access_token,
        refresh_token: current_user.refresh_token,
        redirect_url: "urn:ietf:wg:oauth:2.0:oob",
        expires_in: Time.now + 1_000_000
      )
      @drive = Google::Apis::GroupssettingsV1::GroupssettingsService.new
    end

    def service
      files = @drive.get_group("rowery-kw-krakow@googlegroups.com", options: { authorization: @auth })
      byebug
    end
  end
end
