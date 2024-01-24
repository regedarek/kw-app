# == Schema Information
#
# Table name: topr_records
#
#  id               :bigint           not null, primary key
#  avalanche_degree :integer
#  statement        :text
#  time             :date
#  topr_degree      :string
#  topr_pdf         :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
module Scrappers
  class ToprRecord < ActiveRecord::Base
    self.table_name = 'topr_records'

    mount_uploader :topr_pdf, ToprPdfUploader
    mount_uploader :topr_degree, ToprDegreeUploader
  end
end
