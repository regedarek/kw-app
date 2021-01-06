module UserManagement
  class ListsController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def new
      @profile = Db::Profile.find(params[:profile_id])
      I18n.locale = @profile.locale
      @list = @profile.build_list
    end

    def create
      @profile = Db::Profile.find(params[:profile_id])
      @list = @profile.build_list(list_params)

      I18n.locale = @profile.locale
      if @list.save
        redirect_to root_path, notice: I18n.t('user_management.lists.create.success')
      else
        @errors = @list.errors.full_messages
        render :new
      end
    end

    def accept
      @list = UserManagement::ProfileListRecord.find(params[:id])
      @list.update(
        acceptor_id: current_user.id,
        accepted: true
      )

      ProfileMailer.apply(@list.profile).deliver_later
      @list.profile.update(sent_at: Time.zone.now)

      redirect_to admin_profile_path(@list.profile.id), notice: 'Zaakceptowano wykaz'
    end

    private

    def list_params
      params.require(:list).permit(:description, :section_type, attachments: [])
    end
  end
end
