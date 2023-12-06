class LikesController < ApplicationController
  def create
    case like_params[:likeable_type]
    when  "PhotoCompetition::RequestRecord"
      category = PhotoCompetition::RequestRecord.find(like_params[:likeable_id]).category
      if current_user.likes.any?{|like| like.likeable.category == category}
        return redirect_back(fallback_location: root_path, alert: 'Możesz oddać tylko jeden głos w kategorii!') if current_user.likes.any?
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
