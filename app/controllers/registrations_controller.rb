class RegistrationsController < Devise::RegistrationsController

  protected

  def update_resource(resource, params)
    resource.update_without_password(params)
    profile = Db::Profile.find_by(kw_id: resource_params.fetch(:kw_id))
    profile.update(resource_params.permit(:kw_id, :first_name, :last_name, :email).to_h) if profile.present?
  end
end
