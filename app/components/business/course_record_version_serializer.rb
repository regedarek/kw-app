module Business
  class CourseRecordVersionSerializer < ActiveModel::Serializer
    attributes :id, :item_type, :item_id, :event, :whodunnit, :object,
      :created_at, :object_changes

    def item
      object.item_type.constantize.find_by(id: object.item_id)
    end

    def title
      item&.name
    end

    def changer_name
      Db::User.find_by(id: object.whodunnit)&.display_name
    end

    def item_human_name
      'Kurs'
    end

    def created_at_to_s
      object.created_at.strftime '%Y-%m-%d %H:%M:%S'
    end

    def event
      object.event
    end

    def changeset
      object.changeset
    end

    def sign_up_link
      false
    end

    def course_link
      "/courses/#{object.item_id}"
    end
  end
end
