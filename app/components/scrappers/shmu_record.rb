module Scrappers
  class ShmuRecord < ActiveRecord::Base
    self.table_name = 'shmu_diagrams'

    mount_uploader :image, ImageUploader
  end
end
