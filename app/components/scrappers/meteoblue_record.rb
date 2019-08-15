module Scrappers
  class MeteoblueRecord < ActiveRecord::Base
    self.table_name = 'meteoblue_records'

    mount_uploader :meteogram, MeteoblueUploader
  end
end
