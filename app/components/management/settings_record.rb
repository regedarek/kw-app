# == Schema Information
#
# Table name: settings
#
#  id           :bigint           not null, primary key
#  back_url     :string
#  content      :text
#  content_type :integer          default("rules"), not null
#  name         :string           not null
#  path         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
module Management
  class SettingsRecord < ActiveRecord::Base
    self.table_name = 'settings'
    enum content_type: [:rules, :segment]
  end
end
