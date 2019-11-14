module Activities
  class CompetitionsTable
    include ActionView::Helpers::AssetTagHelper
    include Rails.application.routes.url_helpers
    ApplicationController.append_view_path Rails.root.join('app', 'components', 'activities')

    def call
      ApplicationController.render(partial: "api/competitions/table", locals: { competitions: Activities::CompetitionRecord.all })
    end
  end
end
