module Business
  class SignUpRecordVersionSerializer < ActiveModel::Serializer
    attributes :id, :item_type, :item_id, :event, :whodunnit, :object,
      :created_at, :object_changes

    def item
      object.item_type.constantize.find_by(id: object.item_id)
    end

    def title
      if object.item&.course
        object.item.course&.name
      else
        Business::CourseRecord.find_by(id: object.changeset&.dig("course_id")&.first)&.name || 'Usunięty'
      end
    end

    def changer_name
      if item
        item.name
      else
        if object.object
          YAML.load(object.object).fetch("name")
        else
          if object.event == 'create'
            object.changeset&.dig("name")&.last
          else
            object.changeset&.dig("name")&.first
          end
        end
      end
    end

    def item_human_name
      'Zapis'
    end

    def created_at_to_s
      object.created_at.strftime '%Y-%m-%d %H:%M:%S'
    end

    def event
      object.event
    end

    def course_link
      if object.item
        "/courses/#{object.item.course_id}"
      else
        '/courses/history'
      end
    end

    def sign_up_link
      "/business/sign_ups/#{object.item_id}/edit"
    end

    def changeset
      object.changeset
    end
  end
end
