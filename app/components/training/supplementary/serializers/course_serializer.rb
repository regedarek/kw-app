module Training
  module Supplementary
    module Serializers
      class CourseSerializer < ActiveModel::Serializer
        attributes :id, :name, :place, :start_date, :end_date, :application_date, :slug, :kind, :limit, :end_application_date
      end
    end
  end
end
