class ProfilesController < ApplicationController
  def new
    @profile_form = UserManagement::ProfileForm.new
  end

  def create
    @profile_form = UserManagement::ProfileForm.build_cleaned(profile_params)
    
    result = UserManagement::UserApplication.create(form: @profile_form)
    result.success { redirect_to root_path, notice: t('.success') }
    result.invalid { |form:| render :new, form: form }
    result.else_fail!
  end

  def show
    respond_to do |format|
      format.pdf { send_profile_pdf }
    end
  end

  private

  def download
    PdfGenerator::Download.new(Db::Profile.find(params[:id]))
  end

  def send_profile_pdf
    send_file download.to_pdf, download_attributes
  end

  def download_attributes
    {
      filename: download.filename,
      type: "application/pdf",
      disposition: "inline"
    }
  end

  def profile_params
    params.require(:profile).permit(
      :email, :pesel, :first_name, :last_name, :phone,
      :birth_date, :birth_place, :city, :postal_code, :main_address,
      :optional_address, :main_discussion_group, :terms_of_service,
      recommended_by: [], acomplished_courses: [], sections: []
    )
  end
end 
