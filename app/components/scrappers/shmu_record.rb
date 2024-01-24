# == Schema Information
#
# Table name: shmu_diagrams
#
#  id           :bigint           not null, primary key
#  diagram_time :datetime
#  image        :string
#  place        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
module Scrappers
  class ShmuRecord < ActiveRecord::Base
    self.table_name = 'shmu_diagrams'

    mount_uploader :image, ImageUploader
  end
end
