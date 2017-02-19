class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = Db::User.from_omniauth(request.env["omniauth.auth"])

    if @user.present?
      flash[:notice] = I18n.t('devise.omniauth_callbacks.success', kind: 'Google')
      sign_in_and_redirect @user, :event => :authentication
    else
      session['devise.google_data'] = request.env['omniauth.auth'].except(:extra)
      redirect_to zarejestruj_url, alert: 'Użytkownik z takim adresem email nie istnieje.'
    end
  end
end
