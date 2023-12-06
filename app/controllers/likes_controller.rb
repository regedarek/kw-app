class LikesController < ApplicationController
  def create
    case like_params[:likeable_type]
    when  "PhotoCompetition::RequestRecord"
      edition = PhotoCompetition::RequestRecord.find(like_params[:likeable_id]).edition

      if current_user.likes.select{|like| like.likeable.edition == edition}.count >= 3
        return redirect_back(fallback_location: root_path, alert: 'Możesz oddać tylko 3 głosy w tej edycji!')
      end
    end

    @like = current_user.likes.new(like_params)
    @like.save

    redirect_back(fallback_location: root_path)
  end

  def destroy
    @like = current_user.likes.find(params[:id])
    @like.destroy

    redirect_back(fallback_location: root_path)
  end

  private

  def like_params
    params.require(:like).permit(:likeable_id, :likeable_type)
  end
end
