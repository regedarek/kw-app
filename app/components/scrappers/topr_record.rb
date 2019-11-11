module Scrappers
  class ToprRecord < ActiveRecord::Base
    self.table_name = 'topr_records'

    mount_uploader :topr_pdf, ToprPdfUploader
    mount_uploader :topr_degree, ToprDegreeUploader
  end
end
